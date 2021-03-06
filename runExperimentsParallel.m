delete(gcp('nocreate'))
disp("Start of script")

n = feature('numcores')
thePool = parpool(n)
cd(fileparts(mfilename('fullpath')));
addpath(genpath(cd));

disp("create packages")
packageList = createWorkpackages();
numPackages = size(packageList,1)

disp("Run Packages")
tStart = tic;

packagesInQueue = 0;

for i = 1:numPackages
    pack = packageList(i);
    f(packagesInQueue+1) = parfeval(thePool, @executeWorkpackage, 1, pack);
    packagesInQueue = packagesInQueue + 1;
end

for i = 1:packagesInQueue
    % fetchNext blocks until next results are available.
    [completedIdx,value] = fetchNext(f);
    aString = strcat("For i = ", num2str(i), " : ", value)
end

toc(tStart)
disp("Ende")

function packageList = createWorkpackages()
    numberOfRuns = 31;
    packageList = [];
 %   for alg = ["", "SBX", "RSBX", "DE", "UX", "LCX3", "LX", "CMAX", "R2XD", "R2XS", "NCRXD", "NCRXS", "SRXD", "SRXS", "URXD", "URXS"]
%     for alg = ["R2XS", "NCRXS", "SRXS", "URXS"]
%         for pro = ["RM1", "RM2", "RM3", "RM4", "DTLZ1", "DTLZ2", "DTLZ3", "DTLZ4", "DTLZ5","DTLZ6", "DTLZ7", "DTLZ8", "DTLZ9", "WFG1", "WFG2", "WFG3", "WFG4", "WFG5", "WFG6", "WFG7", "WFG8", "WFG9"]
%             for r = 1:numberOfRuns
%                 packageList = [packageList; struct('alg', alg + "NSGAII", 'pro', pro, 'runNo', r, 'MMulti', 1, 'DMulti', 1, 'MaxFE', 10000, 'savePath', 'std')];
%             end
%         end
%     end
%     
%  %   for alg = ["", "SBX", "RSBX", "DE", "UX", "LCX3", "LX", "CMAX", "R2XD", "R2XS", "NCRXD", "NCRXS", "SRXD", "SRXS", "URXD", "URXS"]
%     for alg = ["R2XS", "NCRXS", "SRXS", "URXS"]
%         for pro = ["RM1", "RM2", "RM3", "RM4", "DTLZ1", "DTLZ2", "DTLZ3", "DTLZ4", "DTLZ5","DTLZ6", "DTLZ7", "DTLZ8", "DTLZ9", "WFG1", "WFG2", "WFG3", "WFG4", "WFG5", "WFG6", "WFG7", "WFG8", "WFG9"]
%             for r = 1:numberOfRuns
%                 packageList = [packageList; struct('alg', alg + "NSGAII", 'pro', pro, 'runNo', r, 'MMulti', 1, 'DMulti', 4, 'MaxFE', 10000, 'savePath', 'harder')];
%             end
%         end
%     end
    
 %   for alg = ["", "SBX", "RSBX", "DE", "UX", "LCX3", "LX", "CMAX", "R2XD", "R2XS", "NCRXD", "NCRXS", "SRXD", "SRXS", "URXD", "URXS"]
    for alg = [ "R2XD", "R2XS", "NCRXD", "NCRXS", "SRXD", "SRXS", "URXD", "URXS"]
        for pro = ["RM1", "RM2", "RM3", "RM4", "DTLZ1", "DTLZ2", "DTLZ3", "DTLZ4", "DTLZ5","DTLZ6", "DTLZ7", "DTLZ8", "DTLZ9", "WFG1", "WFG2", "WFG3", "WFG4", "WFG5", "WFG6", "WFG7", "WFG8", "WFG9"]
            for r = 1:numberOfRuns
                packageList = [packageList; struct('alg', alg + "NSGAII", 'pro', pro, 'runNo', r, 'MMulti', 1, 'DMulti', 6, 'MaxFE', 10000, 'savePath', 'hardest')];
            end
        end
    end
end

function returnValue = executeWorkpackage(package)

    %% RULES
    % Rule #1: Diese Funktion erzeugt keine Ausgaben in die Konsole. Alle
    % Textausgaben sollten als String am Ende im returnValue zur??ckgegeben
    % werden.
    %
    % RULE #2: Diese Funktion ist unabh??ngig von weiteren Aufrufen der
    % Funktion. D.h. die Funktion basiert nicht dadrauf dass vorherige
    % Aufrufe bestimmte Dinge oder Inputargumente berechnet oder auf
    % die Platte geschrieben haben
    %
    % RULE #3: Diese Funktion greift auf gemeinsam genutze Dateien nur
    % lesend zu.
    %
    % RULE #4: Diese Funktion schreibt nur in Dateien, die von keinem
    % weiteren Aufruf der Funktion geschrieben werden. Das hei??t pro
    % Funktionsaufruf eine eindeutige Logfile / Ergebnisfile / etc.
    %

    alg = str2func(package.alg);
    pro = str2func(package.pro);
    run = package.runNo;
    savePath = package.savePath;

    p = pro('DMulti', package.DMulti, 'MMulti', package.MMulti, 'maxFE', package.MaxFE);
    a = alg('runNo',run, 'savePath', savePath, 'save', 20);
    a.Solve(p);

    returnValue = strcat("Successfully ran ", package.alg, " on problem ", package.pro, " with runNo ", num2str(run));

end