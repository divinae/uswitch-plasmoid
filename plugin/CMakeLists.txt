include(ECMQmlModule)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED
    Core
    Qml
)

find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    KIO
    JobWidgets
    Service
)

ecm_add_qml_module(uswitcherplugin URI com.dv.uswitcher.private GENERATE_PLUGIN_SOURCE)
target_sources(uswitcherplugin PRIVATE
    appsmodel.cpp
    appsmodel.h
)

target_link_libraries(uswitcherplugin PRIVATE
    Qt::Core
    Qt::Qml
    KF6::KIOGui
    KF6::JobWidgets
    KF6::Service
)

ecm_finalize_qml_module(uswitcherplugin)
