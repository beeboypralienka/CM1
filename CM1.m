%Tear-down semua variable
clear

%Load file CSV dataset mentah
DatasetCM1 = csvread('CM1.csv');

%load file CSV dataset (remove duplicate)
CM1Unique = csvread('CM1Unique.csv');

% Pembagian fold = 10
k = 10;
vektorCM1 = CM1Unique(:,1);
cvFolds = crossvalind('Kfold', vektorCM1, k);
clear vektorCM1;

% Array 10 baris, 21 kolom
M = cell( 10 , (size(CM1Unique,2)-1) ); %(jumlah fold, jumlah fitur)

% Iterasi fold
for iFold = 1:k    
    
    % Pembagian data training dan testing per setiap fold
    testIdx  = (cvFolds == iFold);                
    trainIdx(:,iFold) = ~testIdx;    
            
    % Menghitung jumlah training, testing, kelas true, dan kelas false
    jmlTraining(iFold,1) = 0;
    jmlTesting(iFold,1) = 0;
    jmlTrue(iFold,1) = 0;
    jmlFalse(iFold,1) = 0;     
    for iBarisCM1Unique = 1 : length(CM1Unique) % Looping 1 - 442
        if trainIdx(iBarisCM1Unique,iFold) == 1 % Mengambil urutan (trainIdx = 1) dengan CM1Unique
            jmlTraining(iFold,1) = jmlTraining(iFold,1) + 1; % Increment jmlTraining jika trainIdx nya 1
            if CM1Unique(iBarisCM1Unique,22) == 1 % Berapa kelas true dan false dari jmlTraining
                jmlTrue(iFold,1) = jmlTrue(iFold,1) + 1; % Increment jmlTrue jika kelas = 1
            else
                jmlFalse(iFold,1) = jmlFalse(iFold,1) + 1; % Increment jmlFalse jika kelas = 0
            end
        else
            jmlTesting(iFold,1) = jmlTesting(iFold,1) + 1; % Increment jmlTesting jika trainIdx nya ~= 1
        end
    end          
    clear iBarisCM1Unique;
        
    % Rumus menghitung entropy parent di tahap EBD dari setiap fold            
    piTrue(iFold,1) = jmlTrue(iFold,1)/jmlTraining(iFold,1);
    piFalse(iFold,1) = jmlFalse(iFold,1)/jmlTraining(iFold,1);
    Log2piTrue(iFold,1) = log2(piTrue(iFold,1));
    Log2piFalse(iFold,1) = log2(piFalse(iFold,1));
    kaliLogTrue(iFold,1) = Log2piTrue(iFold,1) * piTrue(iFold,1);
    kaliLogFalse(iFold,1) = Log2piFalse(iFold,1) * piFalse(iFold,1);
    entropyParent(iFold,1) = abs( kaliLogTrue(iFold,1) + kaliLogFalse(iFold,1) );    
    clear piTrue piFalse Log2piTrue Log2piFalse kaliLogFalse kaliLogTrue;
    
    % Menyederhanakan variable (diringkas menjadi satu metrik)
    keteranganCM1(iFold,:) = [jmlTesting(iFold,:) jmlTraining(iFold,:) jmlTrue(iFold,:) jmlFalse(iFold,:) entropyParent(iFold,:)];
    clear jmlTesting jmlTraining jmlTrue jmlFalse entropyParent;;
    
    % Looping array M dari 1 hingga 21(semua fitur kecuali kelas)
    for z = 1 : size(CM1Unique,2)-1
        % Looping untuk mengisi data dummy berdasarkan jumlah training dari masing-masing fold
        M{iFold,z} = zeros( keteranganCM1(iFold,2) , 2);        		
    end
    clear z iJmlTraining;
    
    % Mengganti data dummy pada array M dengan data training asli
%     for iBarisCell = 1 : 21 %Fitur
%        for iKolomCell = 1 : 10 %Fold
%            for iBarisMetrik = 1 : 442 %Baris Data
%                 for iKolomMetrik = 1 : 2         
%                     for iCocokFitur = 1 : 21
%                         if iBarisCell == iCocokFitur
%                             M{iBarisCell,iKolomCell}(iBarisMetrik,iKolomMetrik) = CM1Unique(iBarisMetrik,iBarisCell);
%                         end
%                         if iKolomMetrik == 2
%                             M{iBarisCell,iKolomCell}(iBarisMetrik,iKolomMetrik) = CM1Unique(iBarisMetrik,22);
%                         end
%                     end                                                
%                 end
%            end
%        end
%     end
    
    
end
  
clear iFold cvFolds iterasi k testIdx;







