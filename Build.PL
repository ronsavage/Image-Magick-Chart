use Module::Build;

Module::Build -> new
(
 module_name    => 'Image::Magick::Chart',
 license        => 'artistic',
 dist_abstract  => 'Use Image::Magick to create charts',
 dist_author    => 'Ron Savage <ron@savage.net.au>',
 build_requires =>
 {
	 Test::More => 0,
	 Test::Pod  => 0,
 },
 configure_requires =>
 {
	 Module::Build => 0.3800,
 },
 requires =>
 {
	 Carp          => 0,
	 Image::Magick => 6.00,
 },
) -> create_build_script();
