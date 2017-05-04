%Tear-down semua display dan variable
clc; clear;

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
MtrainingUrut = cell( 10 , (size(CM1Unique,2)-1) ); %(jumlah fold, jumlah fitur)
Mtesting = cell( 10 , (size(CM1Unique,2)-1) ); %(jumlah fold, jumlah fitur)

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
    entropyParent = entropyParentEBD(jmlTrue,jmlFalse,jmlTraining,iFold);
    
    % Menyederhanakan variable (diringkas menjadi satu metrik)    
    keteranganCM1(iFold,:) = [jmlTesting(iFold,:) jmlTraining(iFold,:) jmlTrue(iFold,:) jmlFalse(iFold,:) entropyParent(iFold,:)];
    clear jmlTesting jmlTraining jmlTrue jmlFalse entropyParent;
    
    % Urutan keteranganCM1 = [1] Testing, [2] Training, [3] TRUE, [4] FALSE, [5] Entropy Parent
        
    % Mengisi data metrik Mtraining dan Mtesting
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi kolom cell berdasarkan jumlah fitur-1
        % iTraining dan iTesting = nge-set nilai metrik array ke berapa untuk ngisi data 
        iTraining = 1; % di Mtraining
        iTesting = 1; % di Mtesting
        for iBarisCM1Unique = 1 : length(CM1Unique) % Looping 1 - 442
            if trainIdx(iBarisCM1Unique,iFold) == 1 % Mengambil urutan (trainIdx = 1) dengan CM1Unique
                MtrainingUrut{iFold,iKolomCell}(iTraining,:) = [CM1Unique(iBarisCM1Unique,iKolomCell) CM1Unique(iBarisCM1Unique,22)]; % Mengisi array metrik[fitur kelas] untuk Mtraining
                MtrainingUrut{iFold,iKolomCell} = sortrows(MtrainingUrut{iFold,iKolomCell}); % Diurutkan berdasarkan kolom pertama
                iTraining = iTraining + 1;
            else % Mengambil urutan (trainIdx ~= 1) dengan CM1Unique
                Mtesting{iFold,iKolomCell}(iTesting,:) = [CM1Unique(iBarisCM1Unique,iKolomCell) CM1Unique(iBarisCM1Unique,22)]; % Mengisi array metrik[fitur kelas] untuk Mtesting
                %Mtesting{iFold,iKolomCell} = sortrows(Mtesting{iFold,iKolomCell}); % Diurutkan berdasarkan kolom pertama
                iTesting = iTesting + 1;
            end
        end        
    end
    clear iTraining iTesting iBarisCM1Unique iKolomCell;        
    
    % Spli data training dengan dijumlah berdasarkan urutan dan dibagi dua
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iDataTraining = 1 : keteranganCM1(iFold, 2)-1 % Looping berdasarkan jumlah TRAINING dari tabel "keteranganCM1"
            MtrainingUrutSplit {iFold,iKolomCell}(iDataTraining,1) = [ ( MtrainingUrut{iFold,iKolomCell}(iDataTraining,1) + MtrainingUrut{iFold,iKolomCell}(iDataTraining+1,1) ) / 2]; % Ditambah dan dibagi dua              
        end        
%         for iDataTesting = 1 : keteranganCM1(iFold, 1)-1 % Looping berdasarkan jumlah TESTING dari tabel "keteranganCM1"
%             MtestingSplit{iFold,iKolomCell}(iDataTesting,1) = [ ( Mtesting{iFold,iKolomCell}(iDataTesting,1) + Mtesting{iFold,iKolomCell}(iDataTesting+1,1) ) / 2];
%         end        
    end
    clear iKolomCell iDataTraining iDataTesting;
    
    % Cari jumlah TRUE dan FALSE serta ENTROPY di Mtraining berdasarkan MtrainingSplit
    % -------------------------------------------------------------------------------------
    jmlTrueKurang = 0;
    jmlFalseKurang = 0;
    jmlTrueLebih = 0;
    jmlFalseLebih = 0;    
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iBarisSplit = 1 : length(MtrainingUrutSplit{iFold,iKolomCell}) % Iterasi baris data berdasarkan setiap data array di MtrainingSplit    
            for iBarisTraining = 1 : length(MtrainingUrut{iFold,iKolomCell}) % Iterasi baris data berdasarkan setiap data array di Mtraining      
                if MtrainingUrut{iFold, iKolomCell}(iBarisTraining,1) <= MtrainingUrutSplit{iFold, iKolomCell}(iBarisSplit,1) % ada berapa data training yang ( <= ) data split                    
                    if MtrainingUrut{iFold, iKolomCell}(iBarisTraining,2) == 1 % Hitung jumlah TRUE dan FALSE pada parameter ( <= )
                        jmlTrueKurang = jmlTrueKurang + 1; % Hitung jumlah TRUE ( <= )                         
                    else
                        jmlFalseKurang = jmlFalseKurang + 1; % Hitung jumlah FALSE ( <= )
                    end
                else % ada berapa data training yang ( > ) data split
                    if MtrainingUrut{iFold, iKolomCell}(iBarisTraining,2) == 1 % Hitung jumlah TRUE dan FALSE pada parameter ( > )
                        jmlTrueLebih = jmlTrueLebih + 1; % Hitung jumlah TRUE ( > )                        
                    else
                        jmlFalseLebih = jmlFalseLebih + 1; % Hitung jumlah FALSE ( > )
                    end
                end
            end    
            
            % Cari entropy child dari parameter ( <= )
            % -------------------------------------------------------------------
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,2) = [jmlTrueKurang]; % Kolom kedua adalah jumlah TRUE dengan parameter ( <= )
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,3) = [jmlFalseKurang]; % Kolom kedua adalah jumlah FALSE dengan parameter ( <= )             
            totalKurang = jmlTrueKurang + jmlFalseKurang; % Total jumlah TRUE dan jumlah FALSE dari parameter ( <= )                        
            if totalKurang ~=0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( <= )
                piTrueKurang(iBarisSplit,1) = jmlTrueKurang / (jmlTrueKurang+jmlFalseKurang); % Hitung jumlah TRUE ( <= )
                piFalseKurang(iBarisSplit,1) = jmlFalseKurang / (jmlTrueKurang+jmlFalseKurang); % Hitung jumlah FALSE ( <= )                
                if piTrueKurang(iBarisSplit,1) == 0 || piFalseKurang(iBarisSplit,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, maka dipastikan entropyChild (<=) juga NOL
                    entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
                else % Jika hasil ( <= ) Pi TRUE dan Pi FALSE bukan NOL
                    % Hitung entropy child ( <= )
                    Log2piTrueKurang(iBarisSplit,1) = log2(piTrueKurang(iBarisSplit,1));
                    Log2piFalseKurang(iBarisSplit,1) = log2(piFalseKurang(iBarisSplit,1));
                    kaliLogTrueKurang(iBarisSplit,1) = Log2piTrueKurang(iBarisSplit,1) * piTrueKurang(iBarisSplit,1);
                    kaliLogFalseKurang(iBarisSplit,1) = Log2piFalseKurang(iBarisSplit,1) * piFalseKurang(iBarisSplit,1);
                    entropyChildKurang(iBarisSplit,1) = abs( kaliLogTrueKurang(iBarisSplit,1) + kaliLogFalseKurang(iBarisSplit,1) );                  
                end                
            else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( <= )
                entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
            end             
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,4) = [entropyChildKurang(iBarisSplit,1)]; % Kolom keempat adalah entropy child dari parameter ( <= )              
            % -------------------------------------------------------------------
            
            % Cari entropy child dari parameter ( > )
            % -------------------------------------------------------------------            
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,5) = [jmlTrueLebih]; % Kolom kelima adalah jumlah TRUE dengan parameter ( > )
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,6) = [jmlFalseLebih]; % Kolom keenam adalah jumlah FALSE dengan parameter ( > )              
            totalLebih = jmlTrueLebih + jmlFalseLebih; % Total jumlah TRUE dan jumlah FALSE dari parameter ( > )                        
            if totalLebih ~= 0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( > )
               piTrueLebih(iBarisSplit,1) = jmlTrueLebih /  (jmlTrueLebih+jmlFalseLebih); % Hitung jumlah TRUE ( > )
               piFalseLebih(iBarisSplit,1) = jmlFalseLebih / (jmlTrueLebih+jmlFalseLebih); % Hitung jumlah FALSE ( > )                
               if piTrueLebih(iBarisSplit,1) == 0 || piFalseLebih(iBarisSplit,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, maka dipastikan entropyChild ( > ) juga NOL                   
                   entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL
               else % Jika hasil ( > ) Pi TRUE dan Pi FALSE bukan NOL                   
                   % Hitung entropy child ( > )
                   Log2piTrueLebih(iBarisSplit,1) = log2(piTrueLebih(iBarisSplit,1));
                   Log2piFalseLebih(iBarisSplit,1) = log2(piFalseLebih(iBarisSplit,1));
                   kaliLogTrueLebih(iBarisSplit,1) = Log2piTrueLebih(iBarisSplit,1) * piTrueLebih(iBarisSplit,1);
                   kaliLogFalseLebih(iBarisSplit,1) = Log2piFalseLebih(iBarisSplit,1) * piFalseLebih(iBarisSplit,1);
                   entropyChildLebih(iBarisSplit,1) = abs( kaliLogTrueLebih(iBarisSplit,1) + kaliLogFalseLebih(iBarisSplit,1) );    
               end
            else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( > )
                entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL
            end            
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,7) = [entropyChildLebih(iBarisSplit,1)]; % Kolom ketujuh adalah entropy child dari parameter ( > )             
            % -------------------------------------------------------------------
            
            jmlTrueKurang = 0;
            jmlFalseKurang = 0;
            jmlTrueLebih = 0;
            jmlFalseLebih = 0;
                        
            % Mencari nilai INFO dari setiap data split
            INFOsplit(iBarisSplit,1) = ( (totalKurang/keteranganCM1(iFold,2))*MtrainingUrutSplit{iFold, iKolomCell}(iBarisSplit,4) + (totalLebih/keteranganCM1(iFold,2))*MtrainingUrutSplit{iFold, iKolomCell}(iBarisSplit,7) );
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,8) = [INFOsplit(iBarisSplit,1)]; % Kolom kedelapan adalah nilai INFO dari data SPLIT 
            
            % Mencari nilai GAIN dari setiap INFO
            GAINinfo(iBarisSplit,1) = keteranganCM1(iFold,5) - INFOsplit(iBarisSplit,1);
            MtrainingUrutSplit{iFold,iKolomCell}(iBarisSplit,9) = [GAINinfo(iBarisSplit,1)];
            
            % Urutan MtrainingSplit = [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN            
        end
        
        % Mencari nilai max Gain dari data split ke berapa
        [Nilai,BarisKe] = max(MtrainingUrutSplit{iFold,iKolomCell}(:,9));
        BestSplit1{iFold,iKolomCell} = [BarisKe Nilai];                
    end
    % -------------------------------------------------------------------------------------
    
    % Diskritisasi data numerik (Training) berdasakan best split
%     for iKolomFold = 1 : size(CM1Unique,2)-1
%         for iBarisData = 1 : keteranganCM1(iFold,2)
%             %CM1diskrit{iFold, iKolomFold}()=
%         end            
%     end
    
end
    clear jmlTrueKurang jmlFalseKurang jmlTrueLebih jmlFalseLebih iBarisSplit iBarisTraining;
    clear iKolomCell entropyChildLebih entropyChildKurang kaliLogFalseKurang kaliLogFalseLebih kaliLogTrueKurang kaliLogTrueLebih;
    clear Log2piFalseKurang Log2piFalseLebih Log2piTrueKurang Log2piTrueLebih piTrueKurang piTrueLebih piFalseKurang piFalseLebih totalKurang totalLebih;
    clear INFOsplit GAINinfo;
    clear iFold cvFolds iterasi k testIdx;
    clear Nilai BarisKe;







