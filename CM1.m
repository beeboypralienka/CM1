% -------------------------------------
% Tear-down semua display dan variable
% -------------------------------------
clc; clear;

% -----------------------------
% Load file CSV dataset mentah
% -----------------------------
DatasetCM1 = csvread('CM1.csv');

% ----------------------------------------
% Load file CSV dataset (remove duplicate)
% ----------------------------------------
CM1Unique = csvread('CM1Unique.csv');

% --------------------
% Pembagian fold = 10
% --------------------
k = 10;
vektorCM1 = CM1Unique(:,1);
cvFolds = crossvalind('Kfold', vektorCM1, k);
clear vektorCM1;

% -------------------------
% Array 10 baris, 21 kolom
% -------------------------
Mtraining = cell( 10 , (size(CM1Unique,2)-1) ); %(jumlah fold, jumlah fitur)
Mtesting = cell( 10 , (size(CM1Unique,2)-1) ); %(jumlah fold, jumlah fitur)

% -------------
% Iterasi fold
% -------------
for iFold = 1:k    
    
    % -----------------------------------------------------
    % Pembagian data training dan testing pada setiap fold
    % -----------------------------------------------------
    testIdx  = (cvFolds == iFold);                
    trainIdx(:,iFold) = ~testIdx;    
            
    % -----------------------------------------------------------------
    % Menghitung jumlah training, testing, kelas true, dan kelas false
    % -----------------------------------------------------------------
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
           
    % ---------------------------------------------------------------------
    % Menghitung entropy parent di tahap EBD dari setiap fold (menggunakan
    % fungsi)
    % ---------------------------------------------------------------------
    entropyParent = entropyParentEBD(jmlTrue,jmlFalse,jmlTraining,iFold);
    
    % -------------------------------------------------------------------
    % Menyederhanakan variable "keteranganCM1" 
    % [1] Testing, [2] Training, [3] TRUE, [4] FALSE, [5] Entropy Parent
    % -------------------------------------------------------------------
    keteranganCM1(iFold,:) = [jmlTesting(iFold,:) jmlTraining(iFold,:) jmlTrue(iFold,:) jmlFalse(iFold,:) entropyParent(iFold,:)];
    clear jmlTesting jmlTraining jmlTrue jmlFalse entropyParent;        
        
    % ------------------------------------------------------------
    % Mengisi data metrik Mtraining dan Mtesting (fitur dan kelas)
    % ------------------------------------------------------------
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi kolom cell berdasarkan jumlah fitur-1
        % iTraining dan iTesting = nge-set nilai metrik array ke berapa untuk ngisi data 
        iTraining = 1; % di Mtraining
        iTesting = 1; % di Mtesting
        for iBarisCM1Unique = 1 : length(CM1Unique) % Looping 1 s.d. 442
            if trainIdx(iBarisCM1Unique,iFold) == 1 % Mengambil urutan CM1Unique berdasarkan trainIdx = 1
                dataFitur = CM1Unique(iBarisCM1Unique,iKolomCell); % Data fitur training
                dataKelas = CM1Unique(iBarisCM1Unique,22); % Data kelas training
                Mtraining{iFold,iKolomCell}(iTraining,:) = [dataFitur dataKelas]; % Mengisi array metrik[fitur,kelas] untuk Mtraining
                MtrainingUrut{iFold,iKolomCell} = sortrows(Mtraining{iFold,iKolomCell}); % Diurutkan berdasarkan kolom pertama
                iTraining = iTraining + 1;
            else % Mengambil urutan (trainIdx ~= 1) dengan CM1Unique
                dataFitur = CM1Unique(iBarisCM1Unique,iKolomCell); % Data fitur testing
                dataKelas = CM1Unique(iBarisCM1Unique,22); % Data fitur testing
                Mtesting{iFold,iKolomCell}(iTesting,:) = [dataFitur dataKelas]; % Mengisi array metrik[fitur,kelas] untuk Mtesting                
                iTesting = iTesting + 1;
            end
        end        
    end
    clear iTraining iTesting iBarisCM1Unique iKolomCell;        
    
    % ---------------------------------------------------------------------------
    % Split data training dengan cara dijumlah berdasarkan urutan dan dibagi dua
    % ---------------------------------------------------------------------------
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iDataTraining = 1 : keteranganCM1(iFold, 2)-1 % Looping berdasarkan data jumlah TRAINING dari tabel "keteranganCM1" dikurangi 1
            dataPertama = MtrainingUrut{iFold,iKolomCell}(iDataTraining,1); % Urutan data untuk split
            dataKedua = MtrainingUrut{iFold,iKolomCell}(iDataTraining+1,1); % Urutan data untuk split
            MtrainingUrutSplit1 {iFold,iKolomCell}(iDataTraining,1) = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1           
        end            
    end
    clear iKolomCell iDataTraining iDataTesting;
    
    % -------------------------------------------------------------------------------------------
    % Cari jumlah TRUE dan FALSE serta nilai ENTROPY di Mtraining berdasarkan MtrainingUrutSplit
    % -------------------------------------------------------------------------------------------
    jmlTrueKurang = 0;
    jmlFalseKurang = 0;
    jmlTrueLebih = 0;
    jmlFalseLebih = 0;    
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iBarisSplit = 1 : length(MtrainingUrutSplit1{iFold,iKolomCell}) % Setiap data split diulang sebanyak jumlah data training
            for iBarisTraining = 1 : length(MtrainingUrut{iFold,iKolomCell}) % Iterasi data training agar match dengan satu data split                  
                % -----------------------------------------------------------
                % Hitung jumlah TRUE dan FALSE dari kategoti ( <= ) dan ( > )
                % -----------------------------------------------------------
                dataAwal = MtrainingUrut{iFold, iKolomCell}(iBarisTraining,1); % Data training
                dataSplit = MtrainingUrutSplit1{iFold, iKolomCell}(iBarisSplit,1); % Data split
                if dataAwal <= dataSplit % ada berapa data training yang ( <= ) data split                    
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
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,2) = jmlTrueKurang; % Jumlah TRUE dengan parameter ( <= ) disimpan di kolom 2
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,3) = jmlFalseKurang; % Jumlah FALSE dengan parameter ( <= ) disimpan di kolom 3
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,5) = jmlTrueLebih; % Jumlah TRUE dengan parameter ( > ) disimpan di kolom 5
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,6) = jmlFalseLebih; % Jumlah FALSE dengan parameter ( > ) disimpan di kolom 6
            
            % -----------------------------------------
            % Cari entropy child dari parameter ( <= )
            % -----------------------------------------                         
            totalKurang = jmlTrueKurang + jmlFalseKurang; % Total jumlah TRUE dan jumlah FALSE dari parameter ( <= )                        
            if totalKurang ~=0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( <= )
                piTrueKurang(iBarisSplit,1) = jmlTrueKurang / (jmlTrueKurang+jmlFalseKurang); % Hitung jumlah TRUE ( <= )
                piFalseKurang(iBarisSplit,1) = jmlFalseKurang / (jmlTrueKurang+jmlFalseKurang); % Hitung jumlah FALSE ( <= )                
                if piTrueKurang(iBarisSplit,1) == 0 || piFalseKurang(iBarisSplit,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild (<=) juga NOL
                    entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
                else % Jika hasil ( <= ) Pi TRUE dan Pi FALSE bukan NOL
                    % ----------------------------
                    % Hitung entropy child ( <= )
                    % ----------------------------
                    Log2piTrueKurang(iBarisSplit,1) = log2(piTrueKurang(iBarisSplit,1));
                    Log2piFalseKurang(iBarisSplit,1) = log2(piFalseKurang(iBarisSplit,1));
                    kaliLogTrueKurang(iBarisSplit,1) = Log2piTrueKurang(iBarisSplit,1) * piTrueKurang(iBarisSplit,1);
                    kaliLogFalseKurang(iBarisSplit,1) = Log2piFalseKurang(iBarisSplit,1) * piFalseKurang(iBarisSplit,1);
                    entropyChildKurang(iBarisSplit,1) = abs( kaliLogTrueKurang(iBarisSplit,1) + kaliLogFalseKurang(iBarisSplit,1) );                  
                end                
            else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( <= ), maka dipastikan entropyChild (<=) juga NOL
                entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
            end             
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,4) = entropyChildKurang(iBarisSplit,1); % Nilai entropy child dari parameter ( <= ) disimpan di kolom 4                          
            
            % ----------------------------------------
            % Cari entropy child dari parameter ( > )
            % ----------------------------------------                         
            totalLebih = jmlTrueLebih + jmlFalseLebih; % Total jumlah TRUE dan jumlah FALSE dari parameter ( > )                        
            if totalLebih ~= 0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( > )
               piTrueLebih(iBarisSplit,1) = jmlTrueLebih /  (jmlTrueLebih+jmlFalseLebih); % Hitung jumlah TRUE ( > )
               piFalseLebih(iBarisSplit,1) = jmlFalseLebih / (jmlTrueLebih+jmlFalseLebih); % Hitung jumlah FALSE ( > )                
               if piTrueLebih(iBarisSplit,1) == 0 || piFalseLebih(iBarisSplit,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild ( > ) juga NOL                   
                   entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL
               else % Jika hasil ( > ) Pi TRUE dan Pi FALSE bukan NOL
                   % ---------------------------
                   % Hitung entropy child ( > )
                   % ---------------------------
                   Log2piTrueLebih(iBarisSplit,1) = log2(piTrueLebih(iBarisSplit,1));
                   Log2piFalseLebih(iBarisSplit,1) = log2(piFalseLebih(iBarisSplit,1));
                   kaliLogTrueLebih(iBarisSplit,1) = Log2piTrueLebih(iBarisSplit,1) * piTrueLebih(iBarisSplit,1);
                   kaliLogFalseLebih(iBarisSplit,1) = Log2piFalseLebih(iBarisSplit,1) * piFalseLebih(iBarisSplit,1);
                   entropyChildLebih(iBarisSplit,1) = abs( kaliLogTrueLebih(iBarisSplit,1) + kaliLogFalseLebih(iBarisSplit,1) );    
               end
            else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( > )
                entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL
            end            
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,7) = entropyChildLebih(iBarisSplit,1); % Nilai entropy child dari parameter ( > ) disimpan di kolom 7                                     
                   
            % -----------------------------------------
            % Mencari nilai INFO dari setiap data split
            % -----------------------------------------
            dataChildKurang = (totalKurang/keteranganCM1(iFold,2)) * MtrainingUrutSplit1{iFold, iKolomCell}(iBarisSplit,4);
            dataChildLebih = (totalLebih/keteranganCM1(iFold,2)) * MtrainingUrutSplit1{iFold, iKolomCell}(iBarisSplit,7);
            INFOsplit(iBarisSplit,1) = (dataChildKurang + dataChildLebih);
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,8) = INFOsplit(iBarisSplit,1); % nilai INFO dari data SPLIT. disimpan di kolom 8
            
            % ------------------------------------
            % Mencari nilai GAIN dari setiap INFO
            % ------------------------------------
            GAINinfo(iBarisSplit,1) = keteranganCM1(iFold,5) - INFOsplit(iBarisSplit,1);
            MtrainingUrutSplit1{iFold,iKolomCell}(iBarisSplit,9) = GAINinfo(iBarisSplit,1); % nilai INFO dari data SPLIT. disimpan di kolom 9
            
            % ----------------------------------------------------------------------
            % Di-NOL-kan, karena jumlah TRUE dan FALSE setiap data split itu berbeda
            % ----------------------------------------------------------------------
            jmlTrueKurang = 0;
            jmlFalseKurang = 0;
            jmlTrueLebih = 0;
            jmlFalseLebih = 0;
            
            % ----------------------------------------------------------------------------------------------------------------------------
            % Penyederhanaan variable "MtrainingUrutSplit" 
            % [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN
            % ----------------------------------------------------------------------------------------------------------------------------                       
        end
        
        % ---------------------------------------------------------------
        % Mencari nilai best split berdasarkan nilai GAIN tertinggi (max)
        % ---------------------------------------------------------------
        [Nilai,BarisKe] = max(MtrainingUrutSplit1{iFold,iKolomCell}(:,9));
        BestSplit1{iFold,iKolomCell} = [BarisKe Nilai]; % nilai max Gain dari data split ke berapa
    end            
    
    % ---------------------------------------------------------------------
    % Diskritisasi data numerik (Training) berdasakan best split ( <= , > )
    % ---------------------------------------------------------------------
    for iKolomDiskrit = 1 : size(CM1Unique,2)-1 % 1 : 21
        for iBarisDiskrit = 1 : keteranganCM1(iFold,2) % 1 : jumlah training dari setiap fold
            keBerapa = BestSplit1{iFold,iKolomDiskrit}(1,1); % Untuk ambil nilai max gain ke berapa
            % ----------------------------------------------------------------------
            % kalau data di array metrik kurang dari sama dengan kriteria EBD ( <= )
            % ----------------------------------------------------------------------
            if Mtraining{iFold, iKolomDiskrit}(iBarisDiskrit,1) <= MtrainingUrutSplit1{iFold, iKolomDiskrit}( keBerapa , 1) 
                %MtrainingDiskrit{iFold, iKolomDiskrit}(iBarisDiskrit,:) = [0 Mtraining{iFold,iKolomDiskrit}(iBarisDiskrit,2)];                
                MtrainingDiskritAll1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 0;
            % --------------------------------------------------------
            % kalau data di array metrik lebih dari kriteria EBD ( > )
            % --------------------------------------------------------
            else
                %MtrainingDiskrit{iFold, iKolomDiskrit}(iBarisDiskrit,:) = [1 Mtraining{iFold,iKolomDiskrit}(iBarisDiskrit,2)];
                MtrainingDiskritAll1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 1;
            end
            % -----------------------------------------------------
            % Menambahkan kolom kelas ke metrik MtrainingDsikritAll
            % -----------------------------------------------------
            if iKolomDiskrit == size(CM1Unique,2)-1 %21              
                dataKelasnya = Mtraining{iFold,iKolomDiskrit}(iBarisDiskrit,2); % ambil data kelas dari Mtraining
                MtrainingDiskritAll1{iFold,1}(iBarisDiskrit,iKolomDiskrit+1) = dataKelasnya; % data kelas disimpan di kolom ke 22
            end                                    
        end           
    end     
    
    % ---------------------------------
    % Distinct data MtrainingDiskritAll1
    % ---------------------------------
    MtrainingUniqueBiner1{iFold,1} = unique(MtrainingDiskritAll1{iFold,1},'rows'); % Data redundan diseleksi (include kelas)
    
    % ----------------------------------------------------------------------------------------------------------------------------------
    % Kalau jumlah data DISTINCT tidak sama dengan jumlah data DiskritALL, maka bisa dipastikan ada duplikasi dengan kelas yang berbeda
    % ----------------------------------------------------------------------------------------------------------------------------------
    jumlahDataUniqueTanpaKelas = length(unique(MtrainingUniqueBiner1{iFold,1}(:,1:21),'rows')); % Data unique tanpa kelas
    if  jumlahDataUniqueTanpaKelas ~= length(MtrainingUniqueBiner1{iFold,1})
        % ---------------------------
        % Perlu dilakukan EBD 2 fase
        % ---------------------------        
        % display(iFold);        
        % MtrainingUrutSplit <----
        % MtrainingUnique <----
        % MtrainingDiskritAll <----
        % BestSplit1 <----
    end
    
    
    
end

% ------------------------------------------------
% Clear semua variable yang sudah tidak diperlukan
% ------------------------------------------------
clear jmlTrueKurang jmlFalseKurang jmlTrueLebih jmlFalseLebih iBarisSplit iBarisTraining;
clear iKolomCell entropyChildLebih entropyChildKurang kaliLogFalseKurang kaliLogFalseLebih kaliLogTrueKurang kaliLogTrueLebih;
clear Log2piFalseKurang Log2piFalseLebih Log2piTrueKurang Log2piTrueLebih piTrueKurang piTrueLebih piFalseKurang piFalseLebih totalKurang totalLebih;
clear INFOsplit GAINinfo;
clear iFold cvFolds iterasi k testIdx;
clear Nilai BarisKe;
clear iBarisDiskrit iKolomDiskrit keBerapa;
clear dataAwal dataChildKurang dataChildLebih dataFitur dataKedua dataKelas dataKelasnya dataPertama dataSplit jumlahDataUniqueTanpaKelas;







