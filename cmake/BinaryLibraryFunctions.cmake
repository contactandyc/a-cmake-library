function(is_header_only_library TARGET RESULT_VAR)
    # Default result to FALSE
    set(${RESULT_VAR} FALSE PARENT_SCOPE)

    message(STATUS "Checking if ${TARGET}::${TARGET} is a header-only library")
    # Check if the target exists
    if(TARGET ${TARGET}::debug)
        message(STATUS "Found ${TARGET}::debug")
        set(${RESULT_VAR} FALSE PARENT_SCOPE)
    else()
        message(STATUS "Header only library ${TARGET}::${TARGET}")
        set(${RESULT_VAR} TRUE PARENT_SCOPE)
    endif()
endfunction()