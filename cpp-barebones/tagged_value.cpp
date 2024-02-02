#pragma once

template <typename T>
struct tagged_value {
    union { T m_contained_val; };
    bool m_has_value;

    bool HasValue(void) {
	return m_has_value;
    }

    T Value(void) {
	return m_contained_val;
    }
};


template <typename T>
tagged_value<T> NoValue(void) {
    tagged_value<T> retval;
    retval.m_has_value = false;
    return retval;
}

template <typename T>
tagged_value<T> SomeValue(T val) {
    tagged_value<T> retval;
    retval.m_contained_val = val;
    retval.m_has_value = true;
    return retval;
}
