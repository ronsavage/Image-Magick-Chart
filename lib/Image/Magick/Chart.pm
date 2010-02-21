package Image::Magick::Chart;

# Name:
#	Image::Magick::Slice.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114
#
# Note:
#	o Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 2005 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;

use Carp;
use Image::Magick;

require 5.005_62;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Image::Magick::Chart ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '1.06';

# -----------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(
	 _antialias            => 0, # 0 => No antialias; 1 => Antialias.
	 _bar_width            => 8, # Pixels.
	 _bg_color             => 'white',
	 _colorspace           => 'RGB',
	 _depth                => 8, # Bits per channel.
	 _fg_color             => 'black',
	 _font                 => 'Courier',
	 _frame_color          => 'black',
	 _frame_option         => 1, # 0 => None; 1 => Draw it.
	 _height               => 0,
	 _image                => '', # To specify the padding in pixels around the frame
	 _output_file_name     => '', # I use CSS-style for the 4 sides of the image:
	 _padding              => [30, 30, 30, 30], # [12 noon, 3, 6, 9].
	 _pointsize            => 14, # Points.
	 _tick_length          => 4,  # Pixels.
	 _title                => '',
	 _width                => 0,
	 _x_axis_data          => [],
	 _x_axis_labels        => [],
	 _x_axis_labels_option => 1, # 0 => None; 1 => Draw them.
	 _x_axis_ticks_option  => 2, # 0 => None; 1 => Below x-axis; 2 => Across frame.
	 _x_data               => [],
	 _x_data_option        => 1,
	 _x_pixels_per_unit    => 3, # Horizontal width of each data unit.
	 _y_axis_data          => [],
	 _y_axis_labels        => [],
	 _y_axis_labels_option => 1,     # 0 => None; 1 => Draw them.
	 _y_axis_labels_x      => undef, # undef => Ignore; Other => Use.
	 _y_axis_ticks_option  => 1,     # 0 => None; 1 => Left of y-axis; 2 => Across frame.
	 _y_pixels_per_unit    => 20,
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _standard_keys
	{
		keys %_attr_data;
	}

}	# End of encapsulated class data.

# -----------------------------------------------

sub draw_frame
{
	my($self)  = @_;
	my($x_max) = $$self{'_x_pixels_per_unit'} * $$self{'_x_axis_data'}[$#{$$self{'_x_axis_data'} }];

	$$self{'_image'} -> Draw
	(
	 fill      => 'none',
	 primitive => 'polyline',
	 stroke    => $$self{'_frame_color'},
	 points    => sprintf
	 (
	  "%i,%i %i,%i %i,%i %i,%i %i,%i",
	  $$self{'_padding'}[3], $$self{'_padding'}[0],
	  $$self{'_padding'}[3] + $x_max, $$self{'_padding'}[0],
	  $$self{'_padding'}[3] + $x_max, ($$self{'_height'} - $$self{'_padding'}[2] - 1),
	  $$self{'_padding'}[3], ($$self{'_height'} - $$self{'_padding'}[2] - 1),
	  $$self{'_padding'}[3], $$self{'_padding'}[0]
	 ),
	) && Carp::croak("Can't draw frame");

}	# End of draw_frame.

# -----------------------------------------------

sub draw_horizontal_bars
{
	my($self)           = @_;
	my($half_bar_width) = int($$self{'_bar_width'} / 2);
	my($y_zero)         = $$self{'_height'} - $$self{'_padding'}[2] - 1;

	my($i, $data, @metric, $x_right, $y_top);

	for $i (0 .. $#{$$self{'_x_data'} })
	{
		$data    = $$self{'_x_data'}[$i];
		$x_right = $$self{'_padding'}[3] + ($$self{'_x_pixels_per_unit'} * $data);
		$y_top   = $y_zero - ($$self{'_y_pixels_per_unit'} * $$self{'_y_axis_data'}[$i]);

		$$self{'_image'} -> Draw
		(
			fill      => $$self{'_fg_color'},
			primitive => 'polyline',
			method    => 'floodfill',
			stroke    => $$self{'_fg_color'},
			points    => sprintf
			(
			 "%i,%i %i,%i %i,%i %i,%i",
			 $$self{'_padding'}[3], $y_top - $half_bar_width,
			 $x_right, $y_top - $half_bar_width,
			 $x_right, $y_top + $half_bar_width,
			 $$self{'_padding'}[3], $y_top + $half_bar_width,
			),
		) && Carp::croak("Can't draw horizontal bars");

		next if ($$self{'_x_data_option'} == 0);

		@metric = $$self{'_image'} -> QueryFontMetrics(text => $data);

		$$self{'_image'} -> Annotate
		(
		 font        => $$self{'_font'},
		 text        => $data,
		 stroke      => 'black',
		 strokewidth => 1,
		 pointsize   => $$self{'_pointsize'},
		 x           => $x_right + $$self{'_tick_length'},
		 y           => $y_top + int($metric[5] / 2) - 2,
		) && Carp::croak("Can't draw horizontal bars");
	}

}	# End of draw_horizontal_bars.

# -----------------------------------------------

sub draw_title
{
	my($self) = @_;

	$$self{'_image'} -> Annotate
	(
	 font        => $$self{'_font'},
	 text        => $$self{'_title'},
	 stroke      => 'black',
	 strokewidth => 1,
	 pointsize   => $$self{'_pointsize'},
	 x           => int( ($$self{'_width'} - int(int($$self{'_pointsize'} / 2) * length($$self{'_title'}) ) ) / 2),
	 y           => int($$self{'_padding'}[0] / 2) + 2,
	) && Carp::croak("Can't draw title");

}	# End of draw_title.

# -----------------------------------------------

sub draw_x_axis_labels
{
	my($self)	= @_;
	my($x_zero)	= $$self{'_padding'}[3];

	my($i, $text, $x_step, @metric);

	for $i (0 .. $#{$$self{'_x_axis_labels'} })
	{
		$text   = $$self{'_x_axis_labels'}[$i];
		$x_step = $x_zero + ($$self{'_x_pixels_per_unit'} * $$self{'_x_axis_data'}[$i]);
		@metric = $$self{'_image'} -> QueryFontMetrics(text => $text);

		$$self{'_image'} -> Annotate
		(
			font        => $$self{'_font'},
			text        => $text,
			stroke      => $$self{'_frame_color'},
			strokewidth => 1,
			pointsize   => $$self{'_pointsize'},
			x           => $x_step - int($metric[4] / 2) - 1,
			y           => $$self{'_height'} - $$self{'_pointsize'},
		) && Carp::croak("Can't draw X-axis labels");
	}

}	# End of draw_x_axis_labels.

# -----------------------------------------------

sub draw_x_axis_ticks
{
	my($self)   = @_;
	my($x_zero) = $$self{'_padding'}[3];
	my($y_zero) = $$self{'_x_axis_ticks_option'} == 1 ? $$self{'_height'} - $$self{'_padding'}[2] : $$self{'_padding'}[0];
	my($y_one)  = $$self{'_height'} - $$self{'_padding'}[2] + $$self{'_tick_length'};

	my($x, $x_step);

	for $x (@{$$self{'_x_axis_data'} })
	{
		$x_step = $x_zero + ($$self{'_x_pixels_per_unit'} * $x);

		$$self{'_image'} -> Draw
		(
			primitive => 'line',
			stroke    => $$self{'_frame_color'},
			points    => sprintf
			(
				"%i,%i %i,%i",
				$x_step, $y_zero,
				$x_step, $y_one
			),
		) && Carp::croak("Can't draw X-axis ticks");
	}

}	# End of draw_x_axis_ticks.

# -----------------------------------------------

sub draw_y_axis_labels
{
	my($self)   = @_;
	my($y_zero) = $$self{'_height'} - $$self{'_padding'}[2] - 1;

	my($y, $offset, @metric);

	for $y (@{$$self{'_y_axis_labels'} })
	{
		@metric = $$self{'_image'} -> QueryFontMetrics(text => $y);
		$offset	= defined($$self{'_y_axis_labels_x'}) ? $$self{'_y_axis_labels_x'} : $$self{'_padding'}[3] - $$self{'_pointsize'} - $metric[4];
		$y_zero -= $$self{'_y_pixels_per_unit'};

		$$self{'_image'} -> Annotate
		(
			font        => $$self{'_font'},
			text        => $y,
			stroke      => $$self{'_frame_color'},
			strokewidth => 1,
			pointsize   => $$self{'_pointsize'},
			x           => $offset,
			y           => $y_zero + int($metric[5] / 2) - 2,
		) && Carp::croak("Can't draw Y-axis labels");
	}

}	# End of draw_y_axis_labels.

# -----------------------------------------------

sub draw_y_axis_ticks
{
	my($self)   = @_;
	my($x_max)  = $$self{'_x_pixels_per_unit'} * $$self{'_x_axis_data'}[$#{$$self{'_x_axis_data'} }];
	my($x_zero) = $$self{'_y_axis_ticks_option'} == 1 ? $$self{'_padding'}[3] : $x_max + $$self{'_padding'}[3];
	my($x_one)  = $$self{'_padding'}[3] - $$self{'_tick_length'};
	my($y_zero) = $$self{'_height'} - $$self{'_padding'}[2] - 1;

	my($i);

	# We use _x_data here and not _y_axis_* so that the number
	# of ticks corresponds to the number of data points, and
	# not to the number of y-axis labels. Remember: The user
	# can - and should - have an empty string as the last
	# label on the y-axis, to make the image pretty.

	for $i (0 .. $#{$$self{'_x_data'} })
	{
		$y_zero -= $$self{'_y_pixels_per_unit'};

		$$self{'_image'} -> Draw
		(
			primitive => 'line',
			stroke    => $$self{'_frame_color'},
			points    => sprintf
			(
				"%i,%i %i,%i",
				$x_zero, $y_zero,
				$x_one, $y_zero
			),
		) && Carp::croak("Can't draw Y-axis ticks");
	}

}	# End of draw_y_axis_ticks.

# -----------------------------------------------

sub new
{
	my($class, %arg) = @_;
	my($self)        = bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	if ($$self{'_image'})
	{
		($$self{'_width'}, $$self{'_height'}) = $$self{'_image'} -> Get('width', 'height');
	}
	else
	{
		$$self{'_width'}  = $$self{'_padding'}[3] + 1 + ($$self{'_x_pixels_per_unit'} * $$self{'_x_axis_data'}[$#{$$self{'_x_axis_data'} }]) + $$self{'_padding'}[1];
		$$self{'_height'} = $$self{'_padding'}[2] + 1 + ($$self{'_y_pixels_per_unit'} * $$self{'_y_axis_data'}[$#{$$self{'_y_axis_data'} }]) + $$self{'_padding'}[0];
		$$self{'_image'}  = Image::Magick -> new(size => "$$self{'_width'} x $$self{'_height'}");

		$$self{'_image'} -> Set(antialias => $$self{'_antialias'}) && Carp::croak("Can't set antialias: $$self{'_antialias'}");
		$$self{'_image'} -> Set(colorspace => $$self{'_colorspace'}) && Carp::croak("Can't set colorspace: $$self{'_colorspace'}");
		$$self{'_image'} -> Set(depth => $$self{'_depth'}) && Carp::croak("Can't set depth: $$self{'_depth'}");
		$$self{'_image'} -> Read("xc:$$self{'_bg_color'}") && Carp::croak("Can't set bg_color color: $$self{'_bg_color'}");
	}

	return $self;

}	# End of new.

# -----------------------------------------------

sub write
{
	my($self) = @_;

	$$self{'_image'} -> Write($$self{'_output_file_name'}) && Carp::croak("Can't write file");

}	# End of write.

# -----------------------------------------------

1;

__END__

=head1 NAME

C<Image::Magick::Chart> - Use Image::Magick to create charts.

=head1 Synopsis

	#!/usr/bin/perl

	use Image::Magick::Chart::HorizontalBars;

	Image::Magick::Chart::HorizontalBars -> new
	(
		antialias            => 0, # 0 => No antialias; 1 => Antialias.
		bar_width            => 8, # Pixels.
		bg_color             => 'white',
		colorspace           => 'RGB',
		depth                => 8, # Bits per channel.
		fg_color             => 'blue',
		font                 => 'Courier',
		frame_color          => 'black',
		frame_option         => 1, # 0 => None; 1 => Draw it.
		height               => 0,
		image                => '',
		output_file_name     => 'image-1.png',
		padding              => [30, 30, 30, 30], # [12 noon, 3, 6, 9].
		pointsize            => 14, # Points.
		tick_length          => 4,  # Pixels.
		title                => 'Percent (%)',
		width                => 0,
		x_axis_data          => [0, 20, 40, 60, 80, 100],
		x_axis_labels        => [0, 20, 40, 60, 80, 100],
		x_axis_labels_option => 1, # 0 => None; 1 => Draw them.
		x_axis_ticks_option  => 2, # 0 => None; 1 => Below x-axis; 2 => Across frame.
		x_data               => [15, 5, 70, 25, 45, 20, 65],
		x_data_option        => 1,
		x_pixels_per_unit    => 3, # Horizontal width of each data unit.
		y_axis_data          => [1 .. 7, 8], # 7 data points, plus 1 to make image pretty.
		y_axis_labels        => [(map{"($_)"} reverse (1 .. 7) ), ''],
		y_axis_labels_option => 1, # 0 => None; 1 => Draw them.
		y_axis_ticks_option  => 1, # 0 => None; 1 => Left of y-axis; 2 => Across frame.
		y_pixels_per_unit    => 20,
	) -> draw();

This code is part of examples/test-chart.pl.

Note: You do not need to specify all the options above, of course, but only those you
wish to differ from the defaults. I've included all options in examples/test-chart.pl
just to save you the effort of having to type them in.

See Image::Magick's documentation page www/perl.html for the list of values supported by
each Image::Magick option.

=head1 Description

C<Image::Magick::Chart> is a pure Perl module.

This module uses C<Image::Magick> as the base of a set of modules which create simple images
of various types. Only C<Image::Magick::Chart::HorizontalBars> is available at this time.

See examples/image-*.png for sample output, and examples/test-chart.pl for the program
which created those samples.

You control the size of the image by specifying the data values for X and Y, and also by
specifying the scaling factors in the X and Y directions in terms of pixels per unit of data.

Eg: In the above code, the x-axis data ranges up to 100 (sic), and the x-axis scaling factor
is 3 pixels/unit, so the part of the image occupied by the data will be 3 * 100 + 1 pixels wide.
The 1 is for the y-axis.

The 100 comes from max(last value in @$x_axis_data, last value in @$x_data).

=head1 Distributions

This module is available both as a Unix-style distro (*.tgz) and an
ActiveState-style distro (*.ppd). The latter is shipped in a *.zip file.

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing each type of distro.

=head1 Constructor and initialization

new(...) returns an C<Image::Magick::Chart> object.

This is the class's contructor.

Usage: Image::Magick::Chart -> new().

Note: Actually, you don't normally do this.

Instead, you call: Image::Magick::Chart::HorizontalBars -> new(...) -> draw().

This method takes a set of parameters. Only the output_file_name parameter is mandatory.

For each parameter you wish to use, call new as new(param_1 => value_1, ...).

Parameters:

=over 4

=item antialias

The value, 0 or 1, is passed to Image::Magick, if this module creates the image.

See the 'image' option if you wish to use a pre-existing object of type Image::Magick.

Using a value of 1 will make your output file slightly larger.

The default value is 0.

This parameter is optional.

=item bar_width

This is the thickness of the bars, in pixels.

The default value is 8 pixels.

This parameter is optional.

=item bg_color

This is the background color of the image, if this module creates the image.

See the 'image' option if you wish to use a pre-existing object of type Image::Magick.

The default value is 'white'.

This parameter is optional.

=item colorspace

The value, 'RGB' etc, is passed to Image::Magick, if this module creates the image.

See the 'image' option if you wish to use a pre-existing object of type Image::Magick.

This parameter is optional.

=item depth

This is the number of bits per color channel.

The default value is 8.

This parameter is optional.

=item fg_color

This is the color of the horizontal bars, when using C<Image::Magick::Chart::HorizontalBars>.

The default value is 'black'.

This parameter is optional.

=item font

This is the font used for:

=over 4

=item The x-axis labels

=item The y-axis labels

=item The title on top of the image

=item The labels (values) on top of (to the right of) the horizontal bars

=back

The default value is 'Courier'.

This parameter is optional.

=item frame_color

This is the color used to draw a frame around the area of the image which is
actually occupied by the data.

The default color is 'black'.

This parameter is optional.

=item frame_option

The value, 0 or 1, determines whether (1) or not (0) the frame will be drawn.

The default value is 1.

This parameter is optional.

=item height

This is the calculated height of the image, taking into account the area occupied by
the data (the framed area), and the padding on the 4 sides of the frame.

If you use a pre-existing object of type Image::Magick, this module will get the
values for width and height from that image.

This parameter is optional.

=item image

This is the object of type Image::Magick used to manage the image.

This module creates this object by default, but you can pass in to the constructor
a pre-existing object of type Image::Magick, and this module will use your object.

If you use you own object, I assume you have set these parameters for your image:

=over 4

=item antialias

=item bg_color

=item colorspace

=item depth

=back

By which I mean this module will not attempt to set those 4 options when you pass
in a pre-existing object.

This parameter is optional.

=item output_file_name

This is the path, filename and extension to the file where the image will be written.

There is no default.

This parameter is mandatory.

=item padding

This is a array ref of values, in pixels, to leave on all 4 sides of the image, between
the edge of the image and the part occupied by data (the framed part).

You must provide an array ref of 4 values for this parameter.

A clockface is used to define the meanings of the 4 values, thus:

=over 4

=item $$padding[0], the first value, is at the top of the frame

Top corresponds to 12 noon.

=item $$padding[1], the second value, is at the right of the frame

Right corresponds to 3 pm.

Or, if you prefer 3 am, and you think in Spanish, then it's the hour beloved by facists
and other psychopaths: 'de la madrugada'.

=item $$padding[2], the third value, is at the bottom of the frame

Bottom corresponds to 6 pm.

=item $$padding[3], the fourth value, is at the left of the frame

Left corresponds to 9 pm.

=back

The default value is [30, 30, 30, 30].

This parameter is optional.

=item pointsize

This is the size of the text used wherever the 'font' option is used.

The default value is 14.

This parameter is optional.

=item tick_length

This is the length, in pixels, of the tick marks on the x and y axes.

The default value is 4 pixels.

This parameter is optional.

=item title

This is the text written at the top centre of the image.

The default value is '' (the empty string).

This parameter is optional.

=item width

This is the calculated width of the image, taking into account the area occupied by
the data (the framed area), and the padding on the 4 sides of the frame.

If you use a pre-existing object of type Image::Magick, this module will get the
values for width and height from that image.

This parameter is optional.

=item x_axis_data

This is an array ref of X values (abscissas) where you want the x-axis labels and x-axis tick marks
to be drawn.

The values in this array ref are multiplied by the value of the x_pixels_per_unit parameter,
to determine where the x-axis labels and x-axis tick marks are drawn.

The default value is [], meaning neither labels nor tick marks will be drawn along the
x-axis.

This parameter is optional.

Warning: Do not confuse this parameter with the x_data parameter.

=item x_axis_labels

This is an array ref of labels to draw below the x-axis. The X values - around which these
labels are centered - are supplied by the value of the x_axis_data option.

In order to draw the x_axis_data values (abscissas) themselves as x-axis labels, just pass in the same
array ref for both the x_axis_data parameter and the x_axis_labels parameter.

The default value is [], meaning no labels are drawn below the x-axis.

This parameter is optional.

=item x_axis_labels_option

The value, 0 or 1, determines whether (1) or not (0) the x-axis labels will be drawn.

The default value is 1.

This parameter is optional.

=item x_axis_ticks_option

Values:

=over 4

=item '0'

Do not draw x-axis tick marks.

The quotes are just to stop the zero disappearing when POD is converted to HTML.

=item 1

Draw x-axis tick marks below the x-axis.

=item 2

Draw x-axis tick marks across the frame and below the x-axis.

=back

The lengths of the tick marks below the x-axis is given by the value of the
tick_length parameter.

The default value is 1.

This parameter is optional.

=item x_data

This is the array ref of data to use to draw the horizontal bars.

Also, these values are drawn on top of (to the right of) the bars. This can
be turned off with the x_data_option parameter.

This parameter is optional.

=item x_data_option

The value, 0 or 1, determines whether (1) or not (0) the X values given by
the x_data parameter will be drawn on top of (to the right of) the bars.

The default value is 1.

This parameter is optional.

=item x_pixels_per_unit

This is the scaling factor in the x-axis direction.

The default value is 3, meaning each unit of data in the x-axis direction will
occupy 3 pixels horizontally.

This value is used in conjunction with the x_axis_data and x_data parameters.

Eg: In the above code, the x-axis data ranges up to 100 (sic), and the x-axis scaling factor
is 3 pixels/unit, so the part of the image occupied by the data will be 3 * 100 + 1 pixels wide.
The 1 is for the y-axis.

The 100 comes from max(last value in @$x_axis_data, last value in @$x_data).

This parameter is optional.

=item y_axis_data

This is an array ref of Y values (ordinates) where you want the y-axis labels and y-axis tick marks
to be drawn.

The values in this array ref are multiplied by the value of the y_pixels_per_unit parameter,
to determine where the y-axis labels and y-axis tick marks are drawn.

The number of elements in this array ref should be the same as the number of elements in the
array ref given by the x_data parameter.

Or, if you want the image to look pretty, put one more value into the y_axis_data array ref,
as seen in the code above. Do the same with the y_axis_labels parameter - just make the final
value in @$y_axis_labels a '' (the empty string).

The default value is [], meaning neither labels nor tick marks will be drawn along the
y-axis.

This parameter is optional.

=item y_axis_labels

This is an array ref of labels to draw left of the y-axis. The Y values where these labels
are drawn is supplied by the value of the y_axis_data option.

The default value is [], meaning no labels are drawn left of the y-axis.

This parameter is optional.

=item y_axis_labels_option

The value, 0 or 1, determines whether (1) or not (0) the y-axis labels will be drawn.

The default value is 1.

This parameter is optional.

=item y_axis_labels_x

The value, if not undef, determines the x-axis value (abscissa) at which y-axis labels are written.

The special value undef means this module calculates an abscissa at which to start writing
y-axis labels.

This calculation will only produce a pretty-looking column of y-axis labels when all labels are
the same width in pixels. See C<sub draw_y_axis_labels()> for the calculation.

The default value is undef.

This parameter is optional.

=item y_axis_ticks_option

Values:

=over 4

=item '0'

Do not draw y-axis tick marks.

The quotes are just to stop the zero disappearing when POD is converted to HTML.

=item 1

Draw y-axis tick marks left the y-axis.

=item 2

Draw y-axis tick marks across the frame and left of the y-axis.

=back

The lengths of the tick marks left of the y-axis is given by the value of the
tick_length parameter.

The default value is 1.

This parameter is optional.

=item y_pixels_per_unit

This is the scaling factor in the y-axis direction.

The default value is 20, meaning each unit of data in the y-axis direction will
occupy 20 pixels vertically.

This value is used in conjunction with the y_axis_data parameter.

Eg: In the above code, the y-axis data ranges up to 8, and the y-axis scaling factor
is 20 pixels/unit, so the part of the image occupied by the data will be 20 * 8 + 1 pixels high.
The 1 is for the x-axis.

The 8 comes from the last value in @$y_axis_data.

Notice how the label corresponding this value of 8 is '', just to make the image pretty by making
the area occupied by the data (the framed area) a bit higher.

This parameter is optional.

=back

=head1 Method: draw_frame()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: draw_horizontal_bars()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: draw_title()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: draw_x_axis_labels()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: draw_x_axis_ticks()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: draw_y_axis_labels()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: draw_y_axis_ticks()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Method: new(...)

Returns a object of type C<Image::Magick::Chart>.

See above, in the section called 'Constructor and initialization' for details.

=head1 Method: write()

Called by method C<draw()> in C<Image::Magick::Chart::HorizontalBars>.

These is no need to call this method yourself.

=head1 Author

C<Image::Magick::Chart> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2005.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2005, Ron Savage.
	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
