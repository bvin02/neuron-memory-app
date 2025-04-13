#include "whisper.h"
#include "ggml.h"
#include "whisper_params.h"

#include <string>
#include <cstring>

extern "C" {
int run_whisper(const char* modelPath, const char* wavPath, char* outText, int maxLen) {
    struct whisper_context* ctx = whisper_init_from_file(modelPath);
    if (!ctx) return -1;

    whisper_full_params params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
    params.print_progress = false;
    params.print_special = false;
    params.print_realtime = false;
    params.translate = false;

    if (whisper_full(ctx, params, wavPath, 0, 0) != 0) {
        whisper_free(ctx);
        return -2;
    }

    std::string output;
    int n_segments = whisper_full_n_segments(ctx);
    for (int i = 0; i < n_segments; ++i) {
        output += whisper_full_get_segment_text(ctx, i);
        output += " ";
    }

    strncpy(outText, output.c_str(), maxLen);
    whisper_free(ctx);
    return 0;
}
}
