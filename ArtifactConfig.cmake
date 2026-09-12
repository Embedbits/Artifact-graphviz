set(GRAPHVIZ_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
#------------------------------------------------------------------------------#
# Returns artifact version.
#
# The name of function must consist of folder name (graphviz) and postfix 
# (_GetArtifactVersion). Otherwise the buildprocess will fail.  
#
# ARTIFACT_VERSION [out]: Version of artifact in format X.Y.Z
#------------------------------------------------------------------------------#
function(graphviz_GetArtifactVersion RET_VERSION)

    if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
        set(DOT_COMMAND dot.exe)
    else()
        set(DOT_COMMAND dot)
    endif()

    # NOTE: "dot -V" is a documented Graphviz quirk - it prints the version
    # string to STDERR, not stdout (confirmed upstream:
    # https://gitlab.com/graphviz/graphviz/-/issues/1479). ERROR_VARIABLE
    # must be used here, not OUTPUT_VARIABLE.
    execute_process(COMMAND ${DOT_COMMAND} -V
                    ERROR_VARIABLE ARTIFACT_VERSION
                    OUTPUT_QUIET
                    ERROR_STRIP_TRAILING_WHITESPACE)

    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" VERSION "${ARTIFACT_VERSION}")

    set(${RET_VERSION} "${VERSION}" PARENT_SCOPE)

endfunction()


#------------------------------------------------------------------------------#
# Initialize artifact for build.
#
# The name of function must consist of folder name (graphviz) and postfix 
# (_ArtifactInit). Otherwise the buildprocess will fail.  
#
# ARTIFACT_BIN_PATH_ARG [in]: Path to the binary part of artifact
#------------------------------------------------------------------------------#
function(graphviz_ArtifactInit ARTIFACT_BIN_PATH_ARG)

    if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")

        file(GLOB_RECURSE ALL_CONFIG_FILES "${ARTIFACT_BIN_PATH_ARG}/*dot.exe")

        foreach(FILE_PATH IN LISTS ALL_CONFIG_FILES)
            if(FILE_PATH MATCHES "dot.exe")
                get_filename_component(CONFIG_DIR ${FILE_PATH} DIRECTORY)
                break()
            endif()
        endforeach()

        if(CONFIG_DIR)

            message(STATUS "File dot.exe found in: ${CONFIG_DIR}")

            set(ENV{PATH} "${CONFIG_DIR};$ENV{PATH}")

        else()

            message(FATAL_ERROR "File dot.exe not found.")

        endif()

    else()

        file(GLOB_RECURSE ALL_CONFIG_FILES "${ARTIFACT_BIN_PATH_ARG}/*dot")

        foreach(FILE_PATH IN LISTS ALL_CONFIG_FILES)
            if(FILE_PATH MATCHES "dot")
                get_filename_component(CONFIG_DIR ${FILE_PATH} DIRECTORY)
                break()
            endif()
        endforeach()

        if(CONFIG_DIR)

            message(STATUS "File dot found in: ${CONFIG_DIR}")

            set(ENV{PATH} "${CONFIG_DIR}:$ENV{PATH}")

        else()

            message(FATAL_ERROR "File dot not found.")

        endif()

    endif()

    message(DEBUG "Graphviz bin directory added to PATH: ${CONFIG_DIR}")

endfunction()
