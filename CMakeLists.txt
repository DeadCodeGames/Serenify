cmake_minimum_required(VERSION 3.16)

project(Serenify VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(Qt6_DIR "C:\\Qt\\6.8.2\\llvm-mingw_64\\lib\\cmake\\Qt6")
find_package(Qt6 REQUIRED COMPONENTS Quick Core Sql)

set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/sqlite" ${CMAKE_PREFIX_PATH})
find_package(SQLite3 REQUIRED)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appSerenify
    main.cpp
)

qt_add_qml_module(appSerenify
    URI Serenify
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES PlusButton.qml
        QML_FILES TrashButton.qml
        RESOURCES resources.qrc
        RESOURCES Images/Trash.png
        QML_FILES Task.qml
        QML_FILES TimeDateSelector.qml
        SOURCES TaskManager.h
        SOURCES TaskManager.cpp
        SOURCES Task.h
        QML_FILES TaskCreator.qml
        RESOURCES Images/checkmark.png Images/pencil.png
)

qt_add_resources(appSerenify}_resources
    FILES Resources/resources.qrc

)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appSerenify PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appSerenify
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appSerenify PRIVATE ${SQLite3_INCLUDE_DIRS})

target_link_libraries(appSerenify
    PRIVATE Qt6::Quick Qt6::Core Qt6::Sql SQLite::SQLite3
)

include(GNUInstallDirs)
install(TARGETS appSerenify
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
