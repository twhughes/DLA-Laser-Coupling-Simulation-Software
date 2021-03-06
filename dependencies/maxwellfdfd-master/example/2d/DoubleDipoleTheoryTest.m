
%% Set flags.
inspect_only = false;

%% Solve the system.
w = 2;  %spacing
h = 2;  %width of dipole
dl = 1;
c = .5;
dL = 10;
L = 100; %Size/2 of domain
wvlen = 200;
clear solveropts;
hold on;
ps = [];
i = [];
ones = [];
legends = [];
bs = [];
srange = (50:50:50);
lams = (200:20:1800);
for s = srange
    Estrength = [];
    Estrength2 = [];
    Estrength3 = [];
    Estrength4 = [];
    EY = [];
    EZ = [];
    EX = [];
    EY2 = [];
    EZ2 = [];
    EX2 = [];
    EY3 = [];
    EZ3 = [];
    EX3 = [];
    EY4 = [];
    EZ4 = [];
    EX4 = [];
    p2 = [];
    b = (s + w/2)*2;
    L = b*3/2;
    bs = [bs, b];
    for lam = lams
        fprintf('SIZE   = %e\n', s);
        fprintf('LAMBDA = %e\n', lam);
        gray = [.5 .5 .5];
        %No branches
        [E, H, ob_array, src_array, J] = maxwell_run(...
            'OSC', 1e-9, lam, ...
            'DOM', {'vacuum', 'none', 1.0}, [-L-10 L+10; -L-10 L+10; 0 1], [dl,dl,1] , BC.p, [10 10 0], ...
            'OBJ', {'vacuum', 'none', 1.0}, Box([-w/2 w/2; -w/2 w/2; 0 1], 1), ...
            'SOBJ', ...  % scatter objects
                {'perfect_conductor', gray, inf}, ...
                    Box([-s-w/2, -w/2; -h/2, h/2; 0, 1]), ... 
                    Box([w/2, s+w/2; -h/2, h/2; 0, 1]), ... 
            'SRCJ', TFSFPlaneSrc([-b b; -b b; 0 1], Axis.y, Axis.x), ...
            inspect_only);
        
        %2^1 Branches
        [E2, H2, ob_array2, src_array2, J2] = maxwell_run(...
            'OSC', 1e-9, lam, ...
            'DOM', {'vacuum', 'none', 1.0}, [-L-10 L+10; -L-10 L+10; 0 1], [dl,dl,1] , BC.p, [10 10 0], ...
            'OBJ', {'vacuum', 'none', 1.0}, Box([-w/2 w/2; -w/2 w/2; 0 1], 1), ...
            'SOBJ', ...  % scatter objects
                {'perfect_conductor', gray, inf}, ...
                    Box([-s-w/2, -w/2; -h/2, h/2; 0, 1]), ... 
                    Box([w/2, s+w/2; -h/2, h/2; 0, 1]), ... 
                    Box([s+w/2 s+w/2+h; -floor(s*c)/2 floor(s*c)/2; 0 1]), ...   
                    Box([-s-w/2-h -s-w/2; -floor(s*c)/2 floor(s*c)/2; 0 1]), ...  % metal slit
            'SRCJ', TFSFPlaneSrc([-b b; -b b; 0 1], Axis.y, Axis.x), ...
            inspect_only);
        
        %2^2 Branches
        [E3, H3, ob_array3, src_array3, J3] = maxwell_run(...
            'OSC', 1e-9, lam, ...
            'DOM', {'vacuum', 'none', 1.0}, [-L-10 L+10; -L-10 L+10; 0 1], [dl,dl,1] , BC.p, [10 10 0], ...
            'OBJ', {'vacuum', 'none', 1.0}, Box([-w/2 w/2; -w/2 w/2; 0 1], 1), ...
            'SOBJ', ...  % scatter objects
                {'perfect_conductor', gray, inf}, ...
                    Box([-s/2*sqrt(5)-w/2, -w/2; -h/2, h/2; 0, 1]), ... 
                    Box([w/2, s/2*sqrt(5)+w/2; -h/2, h/2; 0, 1]), ...
            'SRCJ', TFSFPlaneSrc([-b b; -b b; 0 1], Axis.y, Axis.x), ...
            inspect_only);        

        %%
        opts.withobjsrc = true;
        vis2d(E{Axis.x}, Axis.z, 0, ob_array, src_array);

        [Xsize,Ysize,Zsize] = size(E{Axis.x}.array());
        Xsize = floor(Xsize/2);
        Ysize = floor(Ysize/2);
        Zsize = floor(Zsize/2);
        EX = [EX, abs(E{Axis.x}.array(Xsize,Ysize,Zsize))^2];
        EY = [EY, abs(E{Axis.y}.array(Xsize,Ysize,Zsize))^2];
        EZ = [EZ, abs(E{Axis.z}.array(Xsize,Ysize,Zsize))^2];
        Estrength = [Estrength, abs(E{Axis.x}.array(Xsize,Ysize,Zsize))^2 ...
                + abs(E{Axis.y}.array(Xsize,Ysize,Zsize))^2 ...
                + abs(E{Axis.z}.array(Xsize,Ysize,Zsize))^2  ];
                       
        [X2size,Y2size,Z2size] = size(E2{Axis.x}.array());
        X2size = floor(X2size/2);
        Y2size = floor(Y2size/2);
        Z2size = floor(Z2size/2);
        EX2 = [EX2, abs(E2{Axis.x}.array(X2size,Y2size,Z2size))^2];
        EY2 = [EY2, abs(E2{Axis.y}.array(X2size,Y2size,Z2size))^2];
        EZ2 = [EZ2, abs(E2{Axis.z}.array(X2size,Y2size,Z2size))^2];
        Estrength2 = [Estrength2, abs(E2{Axis.x}.array(X2size,Y2size,Z2size))^2 ...
                + abs(E2{Axis.y}.array(X2size,Y2size,Z2size))^2 ...
                + abs(E2{Axis.z}.array(X2size,Y2size,Z2size))^2  ];

        [X3size,Y3size,Z3size] = size(E3{Axis.x}.array());
        X3size = floor(X3size/2);
        Y3size = floor(Y3size/2);
        Z3size = floor(Z3size/2);
        EX3 = [EX3, abs(E3{Axis.x}.array(X3size,Y3size,Z3size))^2];
        EY3 = [EY3, abs(E3{Axis.y}.array(X3size,Y3size,Z3size))^2];
        EZ3 = [EZ3, abs(E3{Axis.z}.array(X3size,Y3size,Z3size))^2];
        Estrength3 = [Estrength3, abs(E3{Axis.x}.array(X3size,Y3size,Z3size))^2 ...
                + abs(E3{Axis.y}.array(X3size,Y3size,Z3size))^2 ...
                + abs(E3{Axis.z}.array(X3size,Y3size,Z3size))^2  ];
        lams = [lams,lam];

            
    end
    figure(1);
    title('2-D Line Plot')
    xlabel('wavelength (nm)')
    ylabel('|E(0,0,0)|^2')
    plot(lams, Estrength, 'k.');
    plot(lams, Estrength2, 'b.');
    plot(lams, Estrength3, 'r.');
    legend('0 Branches', '1 Branch', '2 Branches', '3 Branches');

end

