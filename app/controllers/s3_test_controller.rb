class S3TestController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @results = []
    @files = []

    begin
      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        endpoint: ENV['AWS_ENDPOINT_URL'],
        force_path_style: true
      )

      bucket_name = 'test-bucket'

      # バケットが存在しない場合は作成
      begin
        s3_client.create_bucket(bucket: bucket_name)
        @results << "✓ バケット '#{bucket_name}' を作成しました"
      rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
        @results << "✓ バケット '#{bucket_name}' に接続しましたけど"
      end

      # ファイル一覧を取得
      objects = s3_client.list_objects_v2(bucket: bucket_name).contents || []
      @files = objects.map do |obj|
        {
          key: obj.key,
          size: obj.size,
          last_modified: obj.last_modified
        }
      end

    rescue => e
      @results << "✗ エラー: #{e.class} - #{e.message}"
    end
  end

  def upload
    if params[:file].present?
      begin
        s3_client = Aws::S3::Client.new(
          region: ENV['AWS_REGION'],
          endpoint: ENV['AWS_ENDPOINT_URL'],
          force_path_style: true
        )

        bucket_name = 'test-bucket'
        file = params[:file]
        
        s3_client.put_object(
          bucket: bucket_name,
          key: file.original_filename,
          body: file.read,
          content_type: file.content_type
        )

        redirect_to s3_test_index_path, notice: "ファイル '#{file.original_filename}' をアップロードしました"
      rescue => e
        redirect_to s3_test_index_path, alert: "エラー: #{e.message}"
      end
    else
      redirect_to s3_test_index_path, alert: "ファイルを選択してください"
    end
  end

  def download
    begin
      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        endpoint: ENV['AWS_ENDPOINT_URL'],
        force_path_style: true
      )

      bucket_name = 'test-bucket'
      key = params[:key]
      
      response = s3_client.get_object(bucket: bucket_name, key: key)
      
      send_data response.body.read,
        filename: key,
        type: response.content_type,
        disposition: 'attachment'
    rescue => e
      redirect_to s3_test_index_path, alert: "ダウンロードエラー: #{e.message}"
    end
  end

  def delete
    begin
      s3_client = Aws::S3::Client.new(
        region: ENV['AWS_REGION'],
        endpoint: ENV['AWS_ENDPOINT_URL'],
        force_path_style: true
      )

      bucket_name = 'test-bucket'
      key = params[:key]
      
      s3_client.delete_object(bucket: bucket_name, key: key)
      
      redirect_to s3_test_index_path, notice: "ファイル '#{key}' を削除しました"
    rescue => e
      redirect_to s3_test_index_path, alert: "削除エラー: #{e.message}"
    end
  end
end
