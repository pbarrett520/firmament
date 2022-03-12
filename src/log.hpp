// @note @spader 9/3/2019: Fucking unhygienic enums. Can't use Console in an enum because I have a class
// that is also named Console.
// @note @spader 2/17/2020: use enum class bro
namespace Log_Flags {
	uint8_t Console = 1;
	uint8_t File    = 2;
	uint8_t Default = 3; // 1 | 2
};

#define LOG_BUFFER_SIZE 2048

struct Log {
	std::ofstream log_stream;
	char buffer[LOG_BUFFER_SIZE];
	
	void init();
	void write(std::string message, uint8_t flags = Log_Flags::Default);
	void write(const char* fmt, ...);
	void write(uint8_t flags, const char* fmt, ...);
	void write_impl(uint8_t flags, const char* fmt, va_list args);
	void zero_buffer();
};
Log tdns_log;

void Log::init() {
	log_stream.open(fm_log, std::ofstream::out | std::ofstream::trunc);
	zero_buffer();
}

void Log::zero_buffer() {
	memset(&buffer[0], 0, LOG_BUFFER_SIZE);
}

void Log::write(std::string message, uint8_t flags) {
	if (flags & Log_Flags::Console)
		std::cout << message << std::endl;
	if (flags & Log_Flags::File)
		log_stream << message << std::endl;
}

void Log::write(const char* fmt, ...) {
	va_list fmt_args;
	va_start(fmt_args, fmt);
	write_impl(Log_Flags::Default, fmt, fmt_args);
	va_end(fmt_args);
}

void Log::write(uint8_t flags, const char* fmt, ...) {
	va_list fmt_args;
	va_start(fmt_args, fmt);
	write_impl(flags, fmt, fmt_args);
	va_end(fmt_args);
}

void Log::write_impl(uint8_t flags, const char* fmt, va_list fmt_args) {
	vsnprintf(&buffer[0], LOG_BUFFER_SIZE, fmt, fmt_args);

	if (flags & Log_Flags::Console)
		std::cout << buffer << std::endl;
	if (flags & Log_Flags::File)
		log_stream << buffer << std::endl;

	zero_buffer();
}
