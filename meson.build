project ('github.aeldemery.gtk4_list_clock', 'vala', 'c')

sources = files (
    [
        'src/Main.vala',
        'src/Widgets/Clock.vala',
        'src/Widgets/MainWindow.vala',
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
    sources: sources,
    dependencies: dependencies,
    install: true,
)