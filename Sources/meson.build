sources = files (
    [
        'Main.vala',
        'MainWindow.vala',
        
        'Widgets/ClockFace.vala',
        'Widgets/ClockInfoDisplay.vala',

        'Models/TimezonesListModel.vala',
        'Models/TimezoneInfo.vala',

        'Utils/CountryCodeToFlags.vala',
    ]
)

#vapi_dir = meson.current_source_dir() / 'vapi'
#add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

dependencies = [
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('gtk4', version: '>=4.0.0'),
    dependency ('gee-0.8'),
]

executable (
    meson.project_name(),
    sources: [sources, resources],
    dependencies: dependencies,
    install: true,
)