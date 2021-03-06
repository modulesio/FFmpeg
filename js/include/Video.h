#ifndef _HTML_VIDEO_ELEMENT_H_
#define _HTML_VIDEO_ELEMENT_H_

#include <v8.h>
#include <node.h>
#include <nan.h>

extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/avutil.h>
#include <libavutil/time.h>
}

#include <defines.h>

using namespace std;
using namespace v8;
using namespace node;

namespace ffmpeg {

class AppData {
public:
  AppData();
  ~AppData();

  void resetState();
  bool set(vector<unsigned char> &memory, string *error = nullptr);
  static int bufferRead(void *opaque, unsigned char *buf, int buf_size);
  static int64_t bufferSeek(void *opaque, int64_t offset, int whence);
  double getTimeBase();
  bool advanceToFrameAt(double timestamp);

public:
  std::vector<unsigned char> data;
  int64_t dataPos;

	AVFormatContext *fmt_ctx;
	AVIOContext *io_ctx;
	int stream_idx;
	AVStream *video_stream;
	AVCodecContext *codec_ctx;
	AVCodec *decoder;
	AVPacket *packet;
	AVFrame *av_frame;
	AVFrame *gl_frame;
	struct SwsContext *conv_ctx;
};

class Video : public ObjectWrap {
public:
  static Handle<Object> Initialize(Isolate *isolate);
  bool Load(uint8_t *bufferValue, size_t bufferLength, string *error = nullptr);
  void Update();
  void Play();
  void Pause();
  uint32_t GetWidth();
  uint32_t GetHeight();

protected:
  static NAN_METHOD(New);
  static NAN_METHOD(Load);
  static NAN_METHOD(Update);
  static NAN_METHOD(Play);
  static NAN_METHOD(Pause);
  static NAN_GETTER(WidthGetter);
  static NAN_GETTER(HeightGetter);
  static NAN_GETTER(DataGetter);
  static NAN_GETTER(CurrentTimeGetter);
  static NAN_SETTER(CurrentTimeSetter);
  static NAN_GETTER(DurationGetter);
  static NAN_METHOD(UpdateAll);
  double getRequiredCurrentTime();
  double getRequiredCurrentTimeS();
  double getFrameCurrentTimeS();
  bool advanceToFrameAt(double timestamp);
  
  Video();
  ~Video();

  private:
    AppData data;
    bool loaded;
    bool playing;
    int64_t startTime;
    Nan::Persistent<Uint8ClampedArray> dataArray;
    bool dataDirty;
};

extern std::vector<Video *> videos;

}

#endif
