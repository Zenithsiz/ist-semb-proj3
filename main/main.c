#include "esp_log.h"
#include <stdio.h>

void log_1() {
	int var = 0;
	ESP_LOGE("LOG1", "LOG FOR ERRORS %d", var++);
	ESP_LOGW("LOG1", "LOG FOR WARNINGS %d", var++);
	ESP_LOGI("LOG1", "LOG FOR INFORMATION %d", var++);
	ESP_LOGD("LOG1", "LOG FOR DEBUG %d", var++);
	ESP_LOGV("LOG1", "LOG FOR VERBOSE %d", var++);
}

void log_2() {
	ESP_LOGE("LOG2", "LOG FOR ERRORS");
	ESP_LOGW("LOG2", "LOG FOR WARNINGS");
	ESP_LOGI("LOG2", "LOG FOR INFORMATION");
	ESP_LOGD("LOG2", "LOG FOR DEBUG");
	ESP_LOGV("LOG2", "LOG FOR VERBOSE");
}

void step1() {
	log_1();
	esp_log_level_set("LOG2", ESP_LOG_DEBUG);
	log_2();
}

void step2() {
	int levels[3] = {
		ESP_LOG_ERROR,
		ESP_LOG_WARN,
		ESP_LOG_INFO,
	};

	for (int i = 0; i < 3; i++) {
		esp_log_level_set("*", levels[i]);
		log_1();
		esp_log_level_set("LOG2", ESP_LOG_DEBUG);
		log_2();
	}
}

void step3() {
	esp_log_level_set("LOG1", ESP_LOG_WARN);
	log_1();
	esp_log_level_set("LOG2", ESP_LOG_DEBUG);
	log_2();
}

void app_main(void) {
	//step1();
	//step2();
	//step3();
}
