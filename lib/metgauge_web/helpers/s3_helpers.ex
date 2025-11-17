defmodule Metgauge.Helpers.S3Helpers do  
  def get_bucket() do
    Application.get_env(:ex_aws, :bucket_name)
  end

  def get_file_dir(type) do
    dir = String.to_atom("#{type}_dir")
    Application.get_env(:ex_aws, dir)
  end

  def get_s3_path() do
    Application.get_env(:ex_aws, :s3_path)
  end

  def get_s3_upload_path(type, filename, use_original_filename) do
    extension = filename |> String.split(".") |> List.last() |> String.downcase() |> String.replace("jpeg", "jpg")
    full_filename = 
      if use_original_filename do
        filename
      else
        "#{UUID.uuid4()}.#{extension}"
      end
    "#{get_file_dir(type)}/#{full_filename}"
  end

  def upload_to_s3(%{path: file_path} = _upload_params, type, filename, use_original_filename \\ false) do
    bucket_name = get_bucket()
    s3_path = get_s3_upload_path(type, filename, use_original_filename)

    result = file_path
    |> ExAws.S3.Upload.stream_file
    |> ExAws.S3.upload(bucket_name, s3_path, [timeout: 120_000])
    |> ExAws.request!

    case result do
      %{status_code: 200} -> {:ok, s3_path}
      _ -> {:error, "Not able to upload file"}
    end
  end

  def get_s3_protected_file_path(file_path) do
    bucket_name = get_bucket()
    ExAws.Config.new(:s3) 
    |> ExAws.S3.presigned_url(:get, bucket_name, file_path)
  end

  def get_s3_public_file_path(file_path) do
    "#{get_s3_path()}#{file_path}"
  end

  def binary_to_upload(binary) do
    with {:ok, path} <- Plug.Upload.random_file("upload"),
         {:ok, file} <- File.open(path, [:write, :binary]),
         :ok <- IO.binwrite(file, binary),
         :ok <- File.close(file) do
      %Plug.Upload{path: path}
    end
  end

  def upload_base64_to_s3(base64_str, filename) do
    with {:ok, data} <- Base.decode64(base64_str),
      %Plug.Upload{} = upload <- binary_to_upload(data) do
      upload_to_s3(upload, "image", filename)
    else
      _->
        {:error, :s3_upload_error}
    end
  end
end