test_sources = files (
    'CountryCodeToFlags.vala',
    'UtilsTest.vala',
)

test_dependencies = [
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('gee-0.8'),
]

test_exe = executable('utilstest', sources: test_sources, dependencies: test_dependencies)
test('utilstest', test_exe)