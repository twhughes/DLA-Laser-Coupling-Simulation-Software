%% Rectangle
% Concrete subclass of <ZeroVolShape.html |Shape|> representing a rectangular
% patch.

%%% Description
% |Rectangle| represents the shape of a rectangle on a plane.  It does not have
% a volume, but it is used to force a user-defined primary grid plane and four
% primary grid lines, which corresponds to the four sides of the rectangle, in
% <maxwell_run.html |maxwell_run|>.

%%% Construction
%  shape = Rectangle(normal_axis, intercept, rect)
%  shape = Rectangle(normal_axis, intercept, rect, dl_max)

% *Input Arguments*
%
% * |normal_axis|: axis normal to the plane of the rectangle.  It should be one
% of |Axis.x|, |Axis.y|, |Axis.z|.
% * |intercept|: location of the rectangle in the |normal_axis| direction.
% * |rect|: bounds of the rectangle in the plane.  If |normal_axis == Axis.y|,
% it should be in the format of |[zmin zmax; xmin xmax]|.
% * |dl_max|: maximum grid size allowed in the rectangle.  It can be either |[dx
% dy dz]| or a single real number |dl| for |dx = dy = dz|.  If unassigned,
% |dl_max = Inf| is used.  In the |normal_axis| direction, |dl_max| is
% meaningless.

%%% Example
%   % Create an instance of Rectangle.
%   shape = Rectangle(Axis.z, 100, [0 100; 0 100]);
%
%   % Use the constructed shape in maxwell_run().
%   [E, H] = maxwell_run({INITIAL ARGUMENTS}, 'OBJ', {'vacuum', 'none', 1.0}, shape, {REMAINING ARGUMENTS});

%%% See Also
% <Plane.html |Plane|>, <Line.html |Line|>, <Point.html |Point|>,
% <ZeroVolShape.html |ZeroVolShape|>, <maxwell_run.html |maxwell_run|>

classdef Rectangle < ZeroVolShape
	% Plane is a Shape for a plane.
	
	properties
		normal_axis
		intercept
		rect
	end
		
	methods
        function this = Rectangle(normal_axis, intercept, rect, dl_max)
			chkarg(istypesizeof(normal_axis, 'Axis'), '"normal_axis" should be instance of Axis.');
			chkarg(istypesizeof(intercept, 'real'), '"intercept" should be real.');
			chkarg(istypesizeof(rect, 'real', [Dir.count Sign.count]), ...
				'"rect" should be %d-by-%d array with real elements.', Dir.count, Sign.count);

			bound = NaN(Axis.count, Sign.count);
			bound(normal_axis, :) = [intercept intercept];
			[h, v] = cycle(normal_axis);
			bound([h v], :) = rect;
			
			box = Box(bound);
			function level = lsf(r)
				chkarg(istypesizeof(r, 'real', [0, Axis.count]), ...
					'"r" should be matrix with %d columns with real elements.', Axis.count);
				r_normal = r(:, normal_axis);
				r(:, normal_axis) = intercept;  % without this, box.lsf() returns -Inf in most cases, where ZeroVolShape.lsf(r, true) is in vain
				level = box.lsf(r) - abs(r_normal - intercept);
			end
			
			lprim = cell(1, Axis.count);
			for w = Axis.elems
				lprim{w} = box.bound(w,:);
			end
					
			if nargin < 4  % no dl_max
				super_args = {lprim, @lsf};
			else
				dl_max = expand2row(dl_max, Axis.count);
				dl_max(normal_axis) = Inf;  % dl_max is meaningless in normal direction
				super_args = {lprim, @lsf, dl_max};
			end

			this = this@ZeroVolShape(super_args{:});
			this.normal_axis = normal_axis;
			this.intercept = intercept;
			this.rect = rect;
		end
	end	
end
