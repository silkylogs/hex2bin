#pragma once

template <usize t_size> struct text {
    static constexpr usize true_size = t_size + 1;
    char m_chars[true_size];

    template <usize t_src_size> constexpr
    text(char const (&str)[t_src_size]) noexcept {
	for (usize i = 0; i < t_src_size; ++i)
	    m_chars[i] = str[i];
    }

    constexpr static usize len(void) noexcept {
	return t_size;
    }

    char *chars(void) noexcept {
	return m_chars;
    }

    char *begin(void) noexcept {
	return m_chars;
    }

    char *end(void) noexcept {
	return m_chars + t_size;
    }
};

template <usize t_src_size>
text(char const (&)[t_src_size]) -> text<t_src_size - 1>;
