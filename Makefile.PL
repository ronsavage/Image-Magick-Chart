use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'Use Image::Magick to create charts',
    ) : (),
	clean			=>
	{
		FILES		=> 'blib/* Makefile MANIFEST Image-Magick-Chart-*'
	},
	dist			=>
	{
		COMPRESS	=> 'gzip',
		SUFFIX		=> 'gz'
	},
	DISTNAME		=> 'Image-Magick-Chart',
	NAME			=> 'Image::Magick::Chart',
	PL_FILES		=> {},
	PREREQ_PM		=>
	{
		Carp			=> 0,
		Image::Magick	=> 6.00,
		Test::More		=> 0,
		Test::Pod		=> 0,
	},
	VERSION_FROM	=> 'lib/Image/Magick/Chart.pm',
);
