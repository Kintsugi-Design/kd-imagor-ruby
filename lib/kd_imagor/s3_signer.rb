# frozen_string_literal: true

require "openssl"
require "uri"
require "cgi"

module KdImagor
  class S3Signer
    ALGORITHM = "AWS4-HMAC-SHA256"
    SERVICE = "s3"
    UNSIGNED_PAYLOAD = "UNSIGNED-PAYLOAD"

    attr_reader :endpoint, :access_key, :secret_key, :region

    def initialize(endpoint:, access_key:, secret_key:, region: "us-east-1")
      @endpoint = endpoint.to_s.chomp("/")
      @access_key = access_key
      @secret_key = secret_key
      @region = region
    end

    def presigned_get_url(bucket, key, expires_in: 3600)
      presigned_url("GET", bucket, key, expires_in: expires_in)
    end

    def presigned_put_url(bucket, key, content_type: nil, expires_in: 3600)
      headers = {}
      headers["content-type"] = content_type if content_type
      presigned_url("PUT", bucket, key, expires_in: expires_in, headers: headers)
    end

    def presigned_url(method, bucket, key, expires_in: 3600, headers: {})
      validate_credentials!

      uri = build_uri(bucket, key)
      now = Time.now.utc
      date_stamp = now.strftime("%Y%m%d")
      amz_date = now.strftime("%Y%m%dT%H%M%SZ")
      credential_scope = "#{date_stamp}/#{region}/#{SERVICE}/aws4_request"

      signed_headers = build_signed_headers(uri, headers)
      signed_headers_str = signed_headers.keys.sort.join(";")

      query_params = {
        "X-Amz-Algorithm" => ALGORITHM,
        "X-Amz-Credential" => "#{access_key}/#{credential_scope}",
        "X-Amz-Date" => amz_date,
        "X-Amz-Expires" => expires_in.to_s,
        "X-Amz-SignedHeaders" => signed_headers_str
      }

      canonical_query = build_canonical_query(query_params)
      canonical_headers = build_canonical_headers(signed_headers)
      canonical_request = build_canonical_request(
        method,
        uri.path,
        canonical_query,
        canonical_headers,
        signed_headers_str,
        UNSIGNED_PAYLOAD
      )

      string_to_sign = build_string_to_sign(amz_date, credential_scope, canonical_request)
      signing_key = derive_signing_key(date_stamp)
      signature = hmac_hex(signing_key, string_to_sign)

      port_suffix = (uri.port != uri.default_port) ? ":#{uri.port}" : ""
      "#{uri.scheme}://#{uri.host}#{port_suffix}#{uri.path}?#{canonical_query}&X-Amz-Signature=#{signature}"
    end

    private

    def validate_credentials!
      raise MinioError, "MinIO endpoint is required" if endpoint.nil? || endpoint.empty?
      raise MinioError, "MinIO access key is required" if access_key.nil? || access_key.empty?
      raise MinioError, "MinIO secret key is required" if secret_key.nil? || secret_key.empty?
    end

    def build_uri(bucket, key)
      key = key.to_s.sub(%r{^/}, "")
      URI.parse("#{endpoint}/#{bucket}/#{uri_encode_path(key)}")
    end

    def build_signed_headers(uri, additional_headers = {})
      headers = {"host" => uri.host}
      headers["host"] = "#{uri.host}:#{uri.port}" if uri.port != uri.default_port

      additional_headers.each do |k, v|
        headers[k.to_s.downcase] = v.to_s.strip
      end

      headers
    end

    def build_canonical_query(params)
      params.sort.map { |k, v| "#{uri_encode(k)}=#{uri_encode(v)}" }.join("&")
    end

    def build_canonical_headers(headers)
      headers.sort.map { |k, v| "#{k}:#{v}\n" }.join
    end

    def build_canonical_request(method, path, query, headers, signed_headers, payload_hash)
      [
        method,
        path,
        query,
        headers,
        signed_headers,
        payload_hash
      ].join("\n")
    end

    def build_string_to_sign(amz_date, scope, canonical_request)
      [
        ALGORITHM,
        amz_date,
        scope,
        sha256_hex(canonical_request)
      ].join("\n")
    end

    def derive_signing_key(date_stamp)
      k_date = hmac("AWS4#{secret_key}", date_stamp)
      k_region = hmac(k_date, region)
      k_service = hmac(k_region, SERVICE)
      hmac(k_service, "aws4_request")
    end

    def hmac(key, data)
      OpenSSL::HMAC.digest("SHA256", key, data)
    end

    def hmac_hex(key, data)
      OpenSSL::HMAC.hexdigest("SHA256", key, data)
    end

    def sha256_hex(data)
      OpenSSL::Digest::SHA256.hexdigest(data)
    end

    def uri_encode(str)
      CGI.escape(str.to_s).gsub("+", "%20")
    end

    def uri_encode_path(path)
      path.split("/").map { |segment| uri_encode(segment) }.join("/")
    end
  end
end
