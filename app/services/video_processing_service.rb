require 'streamio-ffmpeg'

class VideoProcessingService
  def self.process(video_data)
    temp_input = Tempfile.new(['input', '.mp4'], binmode: true)
    temp_input.write(video_data)
    temp_input.close

    output_path = "#{temp_input.path}.processed.mp4"
    
    movie = FFMPEG::Movie.new(temp_input.path)
    movie.transcode(output_path, video_codec: 'libx264')

    temp_input.unlink
    output_path
  end
end