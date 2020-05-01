project('avelorn', ['vala', 'c'], version: '0.1')

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
sdl2 = dependency('sdl2')
sdl2_gfx = dependency('SDL2_gfx')
sdl2_image = dependency('SDL2_image')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

deps = [glib, gobject, sdl2, sdl2_gfx, sdl2_image]

subdir('src')
