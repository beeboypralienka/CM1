tic

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
           
    % -----------------------------------------------------------------------------------------------
    % Menghitung entropy parent di tahap EBD dari setiap fold (menggunakan fungsi "entropyParentEBD")
    % -----------------------------------------------------------------------------------------------
    entropyParent = entropyParentEBD(jmlTrue,jmlFalse,jmlTraining,iFold);
    
    % -------------------------------------------------------------------
    % Menyederhanakan variable "keteranganCM1" 
    % [1] Testing, [2] Training, [3] TRUE, [4] FALSE, [5] Entropy Parent
    % -------------------------------------------------------------------
    keteranganCM1(iFold,:) = [jmlTesting(iFold,:) jmlTraining(iFold,:) jmlTrue(iFold,:) jmlFalse(iFold,:) entropyParent(iFold,:)];

        
    % ------------------------------------------------------------
    % Mengisi data metrik Mtraining dan Mtesting (fitur dan kelas)
    % ------------------------------------------------------------
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi kolom cell berdasarkan jumlah fitur-1
        % -------------------------------------------------------------------------------
        % iTraining dan iTesting = nge-set nilai metrik array ke berapa untuk ngisi data 
        % -------------------------------------------------------------------------------
        iTraining = 1; % di Mtraining
        iTesting = 1; % di Mtesting
        for iBarisCM1Unique = 1 : length(CM1Unique) % Looping 1 s.d. 442
            if trainIdx(iBarisCM1Unique,iFold) == 1 % Mengambil urutan CM1Unique berdasarkan trainIdx = 1
                dataFitur = CM1Unique(iBarisCM1Unique,iKolomCell); % Data fitur training
                dataKelas = CM1Unique(iBarisCM1Unique,22); % Data kelas training
                Mtraining{iFold,iKolomCell}(iTraining,:) = [dataFitur dataKelas]; % Mengisi array metrik[fitur,kelas] untuk Mtraining
                Mtraining01Urut{iFold,iKolomCell} = sortrows(Mtraining{iFold,iKolomCell}); % Diurutkan berdasarkan kolom pertama
                iTraining = iTraining + 1;
            else % Mengambil urutan (trainIdx ~= 1) dengan CM1Unique
                dataFitur = CM1Unique(iBarisCM1Unique,iKolomCell); % Data fitur testing
                dataKelas = CM1Unique(iBarisCM1Unique,22); % Data fitur testing
                Mtesting{iFold,iKolomCell}(iTesting,:) = [dataFitur dataKelas]; % Mengisi array metrik[fitur,kelas] untuk Mtesting                
                iTesting = iTesting + 1;
            end
        end        
    end

    
    % ---------------------------------------------------------------------------
    % Split data training dengan cara dijumlah berdasarkan urutan dan dibagi dua
    % ---------------------------------------------------------------------------
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iDataTraining = 1 : keteranganCM1(iFold, 2)-1 % Looping berdasarkan data jumlah TRAINING dari tabel "keteranganCM1" dikurangi 1
            dataPertama = Mtraining01Urut{iFold,iKolomCell}(iDataTraining,1); % Urutan data untuk split
            dataKedua = Mtraining01Urut{iFold,iKolomCell}(iDataTraining+1,1); % Urutan data untuk split
            Mtraining02UrutSplit_1 {iFold,iKolomCell}(iDataTraining,1) = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1           
        end            
    end    
    
    % -------------------------------------------------------------------------------------------
    % Cari jumlah TRUE dan FALSE serta nilai ENTROPY di Mtraining berdasarkan MtrainingUrutSplit
    % -------------------------------------------------------------------------------------------
    jmlTrueKurang = 0;
    jmlFalseKurang = 0;
    jmlTrueLebih = 0;
    jmlFalseLebih = 0;    
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iBarisSplit = 1 : length(Mtraining02UrutSplit_1{iFold,iKolomCell}) % Setiap data split diulang sebanyak jumlah data training
            for iBarisTraining = 1 : length(Mtraining01Urut{iFold,iKolomCell}) % Iterasi data training agar match dengan satu data split                  
                % -----------------------------------------------------------
                % Hitung jumlah TRUE dan FALSE dari kategoti ( <= ) dan ( > )
                % -----------------------------------------------------------
                dataAwal = Mtraining01Urut{iFold, iKolomCell}(iBarisTraining,1); % Data training
                dataSplit = Mtraining02UrutSplit_1{iFold, iKolomCell}(iBarisSplit,1); % Data split
                if dataAwal <= dataSplit % ada berapa data training yang ( <= ) data split                    
                    if Mtraining01Urut{iFold, iKolomCell}(iBarisTraining,2) == 1 % Hitung jumlah TRUE dan FALSE pada parameter ( <= )
                        jmlTrueKurang = jmlTrueKurang + 1; % Hitung jumlah TRUE ( <= )                         
                    else
                        jmlFalseKurang = jmlFalseKurang + 1; % Hitung jumlah FALSE ( <= )
                    end
                else % ada berapa data training yang ( > ) data split
                    if Mtraining01Urut{iFold, iKolomCell}(iBarisTraining,2) == 1 % Hitung jumlah TRUE dan FALSE pada parameter ( > )
                        jmlTrueLebih = jmlTrueLebih + 1; % Hitung jumlah TRUE ( > )                        
                    else
                        jmlFalseLebih = jmlFalseLebih + 1; % Hitung jumlah FALSE ( > )
                    end
                end
            end    
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,2) = jmlTrueKurang; % Jumlah TRUE dengan parameter ( <= ) disimpan di kolom 2
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,3) = jmlFalseKurang; % Jumlah FALSE dengan parameter ( <= ) disimpan di kolom 3
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,5) = jmlTrueLebih; % Jumlah TRUE dengan parameter ( > ) disimpan di kolom 5
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,6) = jmlFalseLebih; % Jumlah FALSE dengan parameter ( > ) disimpan di kolom 6                        
            
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
                    entropyChildKurang = entropyChildrenEBD(piTrueKurang, piFalseKurang,iBarisSplit);
                end                
            else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( <= ), maka dipastikan entropyChild (<=) juga NOL
                entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
            end             
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,4) = entropyChildKurang(iBarisSplit,1); % Nilai entropy child dari parameter ( <= ) disimpan di kolom 4                          
            
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
                   entropyChildLebih = entropyChildrenEBD(piTrueLebih, piFalseLebih,iBarisSplit);                   
               end
            else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( > )
                entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL
            end            
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,7) = entropyChildLebih(iBarisSplit,1); % Nilai entropy child dari parameter ( > ) disimpan di kolom 7                                     
                   
            % ----------------------------------------------------------------------
            % Di-NOL-kan, karena jumlah TRUE dan FALSE setiap data split itu berbeda
            % ----------------------------------------------------------------------
            jmlTrueKurang = 0;
            jmlFalseKurang = 0;
            jmlTrueLebih = 0;
            jmlFalseLebih = 0;
            
            % -----------------------------------------
            % Mencari nilai INFO dari setiap data split
            % -----------------------------------------
            dataChildKurang = (totalKurang/keteranganCM1(iFold,2)) * Mtraining02UrutSplit_1{iFold, iKolomCell}(iBarisSplit,4);
            dataChildLebih = (totalLebih/keteranganCM1(iFold,2)) * Mtraining02UrutSplit_1{iFold, iKolomCell}(iBarisSplit,7);
            INFOsplit(iBarisSplit,1) = (dataChildKurang + dataChildLebih);
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,8) = INFOsplit(iBarisSplit,1); % nilai INFO dari data SPLIT. disimpan di kolom 8
            
            % ------------------------------------
            % Mencari nilai GAIN dari setiap INFO
            % ------------------------------------
            GAINinfo(iBarisSplit,1) = keteranganCM1(iFold,5) - INFOsplit(iBarisSplit,1);
            Mtraining02UrutSplit_1{iFold,iKolomCell}(iBarisSplit,9) = GAINinfo(iBarisSplit,1); % nilai INFO dari data SPLIT. disimpan di kolom 9                        
            
            % ----------------------------------------------------------------------------------------------------------------------------
            % Penyederhanaan variable "MtrainingUrutSplit" 
            % [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN
            % ----------------------------------------------------------------------------------------------------------------------------                       
        end
                
        % ---------------------------------------------------------------
        % Mencari nilai best split berdasarkan nilai GAIN tertinggi (max)
        % ---------------------------------------------------------------
        [Nilai,BarisKe] = max(Mtraining02UrutSplit_1{iFold,iKolomCell}(:,9)); % Ambil urutan ke berapa si split terbaik itu dan ambil nilai max gain-nya
        angkaSplit = Mtraining02UrutSplit_1{iFold, iKolomCell}(BarisKe,1); % Angka split terbaik
        Mtraining03BestSplit_1{iFold,iKolomCell} = [BarisKe angkaSplit Nilai]; % nilai max Gain dari data split ke berapa        
    end  
    
    
    
    % ---------------------------------------------------------------------
    % Diskritisasi data numerik (Training) berdasakan best split ( <= , > )
    % ---------------------------------------------------------------------
    for iKolomDiskrit = 1 : size(CM1Unique,2)-1 % 1 : 21
        for iBarisDiskrit = 1 : keteranganCM1(iFold,2) % 1 : jumlah training dari setiap fold
            % splitPertama = Mtraining03BestSplit_1{iFold,iKolomDiskrit}(1,1); % Untuk ambil nilai max gain ke berapa
            % ----------------------------------------------------------------------
            % kalau data di array metrik kurang dari sama dengan kriteria EBD ( <= )
            % ----------------------------------------------------------------------
            if Mtraining{iFold, iKolomDiskrit}(iBarisDiskrit,1) <= Mtraining03BestSplit_1{iFold,iKolomDiskrit}(1,2) %Mtraining02UrutSplit_1{iFold, iKolomDiskrit}( splitPertama , 1)                 
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 0;
            % --------------------------------------------------------
            % kalau data di array metrik lebih dari kriteria EBD ( > )
            % --------------------------------------------------------
            else                
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 1;
            end
            % -----------------------------------------------------
            % Menambahkan kolom kelas ke metrik MtrainingDsikritAll
            % -----------------------------------------------------
            if iKolomDiskrit == size(CM1Unique,2)-1 %21              
                dataKelasnya = Mtraining{iFold,iKolomDiskrit}(iBarisDiskrit,2); % ambil data kelas dari Mtraining
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit+1) = dataKelasnya; % data kelas disimpan di kolom ke 22
            end                                    
        end           
    end   
    
    
    % -------------------------------
    % Distinct data MtrainingBiner_1
    % -------------------------------
    Mtraining05UniqueBiner_1{iFold,1} = unique(Mtraining04Biner_1{iFold,1},'rows'); % Data redundan diseleksi (include kelas)
    
    % --------------------------------------------------------------------------------------------------------------------------------
    % Jika masih ada duplikasi pada "MtrainingUniqueBiner_1" tanpa kelas, maka bisa dipastikan ada duplikasi dengan kelas yang berbeda
    % --------------------------------------------------------------------------------------------------------------------------------
    jumlahDataUniqueTanpaKelas = length(unique(Mtraining05UniqueBiner_1{iFold,1}(:,1:21),'rows')); % Data unique tanpa kelas
    if  jumlahDataUniqueTanpaKelas ~= length(Mtraining05UniqueBiner_1{iFold,1}) % Data unique tanpa kelas ~= data unique
    %---
    
        % --------------------------------
        % Perlu dilakukan split EBD 2 fase
        % --------------------------------               
        for iKolomSplit = 1 : length(Mtraining02UrutSplit_1) % Iterasi kolom, ada 21
            A = 1; % Untuk parameter <=
            B = 1; % Untuk parameter >
            for iDataSplit = 1 : length(Mtraining02UrutSplit_1{iFold,iKolomSplit})-1  % Looping berdasarkan data jumlah split fase pertama dikurangi 1             
                dataPertama = Mtraining02UrutSplit_1{iFold,iKolomSplit}(iDataSplit,1); % Urutan data untuk split
                dataKedua = Mtraining02UrutSplit_1{iFold,iKolomSplit}(iDataSplit+1,1); % Urutan data untuk split
                hasilSplitKedua = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1    
%                 Mtraining02UrutSplit_2{iFold, iKolomSplit}(iDataSplit,1) = hasilSplitKedua; % Nilai dimasukkan ke MtrainingUrutSplit2
                
                % ----------------------------------------------------------------------------------
                % Cek masuk ke kategori <= atau kategori > berdasarkan MtrainingBestSplit sebelumnya
                % ----------------------------------------------------------------------------------
                splitPertama = Mtraining03BestSplit_1{iFold,iKolomSplit}(1,2);
                
                if hasilSplitKedua <= splitPertama
                    Mtraining02UrutSplit_2A{iFold, iKolomSplit}(A,1) = hasilSplitKedua;
                    A = A + 1;
                else
                    Mtraining02UrutSplit_2B{iFold, iKolomSplit}(B,1) = hasilSplitKedua;
                    B = B + 1;
                end                                                
            end
        end
        
        
        % ****************************************************************************************************************************************************************
        % ****************************************************************************************************************************************************************
        
        % -------------------------------------------------------------------------------------------------
        % Cari jumlah TRUE dan FALSE serta nilai ENTROPY di Mtraining berdasarkan "Mtraining02UrutSplit_2A"
        % -------------------------------------------------------------------------------------------------
        jmlTrueKurangA = 0;
        jmlFalseKurangA = 0;
        jmlTrueLebihA = 0;
        jmlFalseLebihA = 0;    
        for iKolomCellA = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
            for iBarisSplitA = 1 : length(Mtraining02UrutSplit_2A{iFold,iKolomCellA}) % Setiap data split diulang sebanyak jumlah data training (Mtraining biasa -2)
                for iBarisTrainingA = 1 : length(Mtraining01Urut{iFold,iKolomCellA}) % Iterasi data training agar match dengan satu data split                                      
                    % -----------------------------------------------------------
                    % Hitung jumlah TRUE dan FALSE dari kategoti ( <= ) dan ( > )
                    % -----------------------------------------------------------
                    dataAwalA = Mtraining01Urut{iFold, iKolomCellA}(iBarisTrainingA,1); % Data training
                    dataSplitA = Mtraining02UrutSplit_2A{iFold, iKolomCellA}(iBarisSplitA,1); % Data split
                    dataKelasA = Mtraining01Urut{iFold, iKolomCellA}(iBarisTrainingA,2); % Data kelas                    
                    if dataAwalA <= dataSplitA % ada berapa data training yang ( <= ) data split                    
                        if  dataKelasA == 1 % Hitung jumlah TRUE pada parameter ( <= )
                            jmlTrueKurangA = jmlTrueKurangA + 1; % Hitung jumlah TRUE ( <= )                         
                        else % Hitung jumlah FALSE pada parameter ( <= )
                            jmlFalseKurangA = jmlFalseKurangA + 1; % Hitung jumlah FALSE ( <= )
                        end
                    else % ada berapa data training yang ( > ) data split
                        if dataKelasA == 1 % Hitung jumlah TRUE dan FALSE pada parameter ( > )
                            jmlTrueLebihA = jmlTrueLebihA + 1; % Hitung jumlah TRUE ( > )                        
                        else
                            jmlFalseLebihA = jmlFalseLebihA + 1; % Hitung jumlah FALSE ( > )
                        end
                    end
                end    
                Mtraining02UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,2) = jmlTrueKurangA; % Jumlah TRUE dengan parameter ( <= ) disimpan di kolom 2
                Mtraining02UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,3) = jmlFalseKurangA; % Jumlah FALSE dengan parameter ( <= ) disimpan di kolom 3
                Mtraining02UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,5) = jmlTrueLebihA; % Jumlah TRUE dengan parameter ( > ) disimpan di kolom 5
                Mtraining02UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,6) = jmlFalseLebihA; % Jumlah FALSE dengan parameter ( > ) disimpan di kolom 6                                
                
                % ---------------------------------------------
                % Cari entropy child "2A" dari parameter ( <= )
                % ---------------------------------------------                       
                totalKurangA = jmlTrueKurangA + jmlFalseKurangA; % Total jumlah TRUE dan jumlah FALSE dari parameter ( <= )              
                if totalKurangA ~=0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( <= )
                    piTrueKurangA(iBarisSplitA,1) = jmlTrueKurangA / (jmlTrueKurangA+jmlFalseKurangA); % Hitung jumlah TRUE ( <= )
                    piFalseKurangA(iBarisSplitA,1) = jmlFalseKurangA / (jmlTrueKurangA+jmlFalseKurangA); % Hitung jumlah FALSE ( <= )                
                    if piTrueKurangA(iBarisSplitA,1) == 0 || piFalseKurangA(iBarisSplitA,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild (<=) juga NOL
                        entropyChildKurangA(iBarisSplitA,1) = 0; % Entropy child ( <= ) dijadikan NOL
                    else % Jika hasil ( <= ) Pi TRUE dan Pi FALSE bukan NOL                    
                        % ----------------------------
                        % Hitung entropy child ( <= )
                        % ----------------------------
                        entropyChildKurangA = entropyChildrenEBD(piTrueKurangA,piFalseKurangA,iBarisSplitA);
                    end                
                else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( <= ), maka dipastikan entropyChild (<=) juga NOL
                    entropyChildKurangA(iBarisSplitA,1) = 0; % Entropy child ( <= ) dijadikan NOL
                end             
                Mtraining02UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,4) = entropyChildKurangA(iBarisSplitA,1); % Nilai entropy child dari parameter ( <= ) disimpan di kolom 4                          

                % --------------------------------------------
                % Cari entropy child "2A" dari parameter ( > )
                % --------------------------------------------                         
                totalLebihA = jmlTrueLebihA + jmlFalseLebihA; % Total jumlah TRUE dan jumlah FALSE dari parameter ( > )                        
                if totalLebihA ~= 0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( > )
                   piTrueLebihA(iBarisSplitA,1) = jmlTrueLebihA / (jmlTrueLebihA+jmlFalseLebihA); % Hitung jumlah TRUE ( > )
                   piFalseLebihA(iBarisSplitA,1) = jmlFalseLebihA / (jmlTrueLebihA+jmlFalseLebihA); % Hitung jumlah FALSE ( > )                
                   if piTrueLebihA(iBarisSplitA,1) == 0 || piFalseLebihA(iBarisSplitA,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild ( > ) juga NOL                   
                       entropyChildLebihA(iBarisSplitA,1) = 0; % Entropy child ( > ) dijadikan NOL
                   else % Jika hasil ( > ) Pi TRUE dan Pi FALSE bukan NOL
                       % ---------------------------
                       % Hitung entropy child ( > )
                       % ---------------------------                    
                       entropyChildLebihA = entropyChildrenEBD(piTrueLebihA, piFalseLebihA,iBarisSplitA);                   
                   end
                else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( > )
                    entropyChildLebihA(iBarisSplitA,1) = 0; % Entropy child ( > ) dijadikan NOL
                end            
                Mtraining02UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,7) = entropyChildLebihA(iBarisSplitA,1); % Nilai entropy child dari parameter ( > ) disimpan di kolom 7 
                
                % ----------------------------------------------------------------------
                % Di-NOL-kan, karena jumlah TRUE dan FALSE setiap data split itu berbeda
                % ----------------------------------------------------------------------                
                jmlTrueKurangA = 0;
                jmlFalseKurangA = 0;
                jmlTrueLebihA = 0;
                jmlFalseLebihA = 0;                                                
            end              
        end
        
        
        % ****************************************************************************************************************************************************************
        
        % -------------------------------------------------------------------------------------------------
        % Cari jumlah TRUE dan FALSE serta nilai ENTROPY di Mtraining berdasarkan "Mtraining02UrutSplit_2B"
        % -------------------------------------------------------------------------------------------------
        jmlTrueKurangB = 0;
        jmlFalseKurangB = 0;
        jmlTrueLebihB = 0;
        jmlFalseLebihB = 0;    
        for iKolomCellB = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
            for iBarisSplitB = 1 : length(Mtraining02UrutSplit_2B{iFold,iKolomCellB}) % Setiap data split diulang sebanyak jumlah data training (Mtraining biasa -2)
                for iBarisTrainingB = 1 : length(Mtraining01Urut{iFold,iKolomCellB}) % Iterasi data training agar match dengan satu data split                                      
                    % -----------------------------------------------------------
                    % Hitung jumlah TRUE dan FALSE dari kategoti ( <= ) dan ( > )
                    % -----------------------------------------------------------
                    dataAwalB = Mtraining01Urut{iFold, iKolomCellB}(iBarisTrainingB,1); % Data training
                    dataSplitB = Mtraining02UrutSplit_2B{iFold, iKolomCellB}(iBarisSplitB,1); % Data split
                    dataKelasB = Mtraining01Urut{iFold, iKolomCellB}(iBarisTrainingB,2); % Data kelas
                    
                    if dataAwalB <= dataSplitB % ada berapa data training yang ( <= ) data split                    
                        if  dataKelasB == 1 % Hitung jumlah TRUE pada parameter ( <= )
                            jmlTrueKurangB = jmlTrueKurangB + 1; % Hitung jumlah TRUE ( <= )                         
                        else % Hitung jumlah FALSE pada parameter ( <= )
                            jmlFalseKurangB = jmlFalseKurangB + 1; % Hitung jumlah FALSE ( <= )
                        end
                    else % ada berapa data training yang ( > ) data split
                        if dataKelasB == 1 % Hitung jumlah TRUE dan FALSE pada parameter ( > )
                            jmlTrueLebihB = jmlTrueLebihB + 1; % Hitung jumlah TRUE ( > )                        
                        else
                            jmlFalseLebihB = jmlFalseLebihB + 1; % Hitung jumlah FALSE ( > )
                        end
                    end
                end    
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,2) = jmlTrueKurangB; % Jumlah TRUE dengan parameter ( <= ) disimpan di kolom 2
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,3) = jmlFalseKurangB; % Jumlah FALSE dengan parameter ( <= ) disimpan di kolom 3
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,5) = jmlTrueLebihB; % Jumlah TRUE dengan parameter ( > ) disimpan di kolom 5
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,6) = jmlFalseLebihB; % Jumlah FALSE dengan parameter ( > ) disimpan di kolom 6                                
                
                % ---------------------------------------------
                % Cari entropy child "2B" dari parameter ( <= )
                % ---------------------------------------------                       
                totalKurangB = jmlTrueKurangB + jmlFalseKurangB; % Total jumlah TRUE dan jumlah FALSE dari parameter ( <= )              
                if totalKurangB ~=0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( <= )
                    piTrueKurangB(iBarisSplitB,1) = jmlTrueKurangB / (jmlTrueKurangB+jmlFalseKurangB); % Hitung jumlah TRUE ( <= )
                    piFalseKurangB(iBarisSplitB,1) = jmlFalseKurangB / (jmlTrueKurangB+jmlFalseKurangB); % Hitung jumlah FALSE ( <= )                
                    if piTrueKurangB(iBarisSplitB,1) == 0 || piFalseKurangB(iBarisSplitB,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild (<=) juga NOL
                        entropyChildKurangB(iBarisSplitB,1) = 0; % Entropy child ( <= ) dijadikan NOL
                    else % Jika hasil ( <= ) Pi TRUE dan Pi FALSE bukan NOL                    
                        % ----------------------------
                        % Hitung entropy child ( <= )
                        % ----------------------------
                        entropyChildKurangB = entropyChildrenEBD(piTrueKurangB,piFalseKurangB,iBarisSplitB);
                    end                
                else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( <= ), maka dipastikan entropyChild (<=) juga NOL
                    entropyChildKurangB(iBarisSplitB,1) = 0; % Entropy child ( <= ) dijadikan NOL
                end             
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,4) = entropyChildKurangB(iBarisSplitB,1); % Nilai entropy child dari parameter ( <= ) disimpan di kolom 4                          

                % --------------------------------------------
                % Cari entropy child "2B" dari parameter ( > )
                % --------------------------------------------                         
                totalLebihB = jmlTrueLebihB + jmlFalseLebihB; % Total jumlah TRUE dan jumlah FALSE dari parameter ( > )                        
                if totalLebihB ~= 0 % Selama total jumlah TRUE dan FALSE bukan NOL pada parameter ( > )
                   piTrueLebihB(iBarisSplitB,1) = jmlTrueLebihB / (jmlTrueLebihB+jmlFalseLebihB); % Hitung jumlah TRUE ( > )
                   piFalseLebihB(iBarisSplitB,1) = jmlFalseLebihB / (jmlTrueLebihB+jmlFalseLebihB); % Hitung jumlah FALSE ( > )                
                   if piTrueLebihB(iBarisSplitB,1) == 0 || piFalseLebihB(iBarisSplitB,1) == 0 % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild ( > ) juga NOL                   
                       entropyChildLebihB(iBarisSplitB,1) = 0; % Entropy child ( > ) dijadikan NOL
                   else % Jika hasil ( > ) Pi TRUE dan Pi FALSE bukan NOL
                       % ---------------------------
                       % Hitung entropy child ( > )
                       % ---------------------------                    
                       entropyChildLebihB = entropyChildrenEBD(piTrueLebihB, piFalseLebihB,iBarisSplitB);                   
                   end
                else % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( > )
                    entropyChildLebihB(iBarisSplitB,1) = 0; % Entropy child ( > ) dijadikan NOL
                end            
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,7) = entropyChildLebihB(iBarisSplitB,1); % Nilai entropy child dari parameter ( > ) disimpan di kolom 7                                 
                
                % ----------------------------------------------------------------------
                % Di-NOL-kan, karena jumlah TRUE dan FALSE setiap data split itu berbeda
                % ----------------------------------------------------------------------
                jmlTrueKurangB = 0;
                jmlFalseKurangB = 0;
                jmlTrueLebihB = 0;
                jmlFalseLebihB = 0;                                
            end                    
        end                
        % ****************************************************************************************************************************************************************
        % ****************************************************************************************************************************************************************                
    %--- 
    else
        disp(iFold);
        disp('joss');
    end            
end

clear iBarisCM1Unique;
    
clear jmlTesting jmlTraining jmlTrue jmlFalse entropyParent;  
    
clear iTraining iTesting iBarisCM1Unique iKolomCell dataFitur dataKelas;      
    
clear iKolomCell iDataTraining dataPertama dataKedua;

clear jmlTrueKurang jmlFalseKurang jmlTrueLebih jmlFalseLebih;
clear iKolomCell iBarisSplit iBarisTraining;
clear dataAwal dataSplit;
clear totalKurang piTrueKurang piFalseKurang entropyChildKurang;
clear Log2piTrueKurang Log2piFalseKurang kaliLogTrueKurang kaliLogFalseKurang;
clear totalLebih piTrueLebih piFalseLebih entropyChildLebih;
clear Log2piTrueLebih Log2piFalseLebih kaliLogTrueLebih kaliLogFalseLebih;    
clear dataChildKurang dataChildLebih INFOsplit GAINinfo;
clear Nilai BarisKe angkaSplit;

clear iKolomDiskrit iBarisDiskrit dataKelasnya;

clear iKolomSplit iDataSplit hasilSplitKedua splitPertama A B dataPertama dataKedua hasilSplitKedua Mtraining02UrutSplit_2;

clear jmlTrueKurangA jmlFalseKurangA jmlTrueLebihA jmlFalseLebihA totalLebihA totalKurangA;
clear piTrueKurangA piFalseKurangA piTrueLebihA piFalseLebihA;
clear entropyChildKurangA entropyChildLebihA;
clear iKolomCellA iBarisSplitA iBarisTrainingA;
clear dataAwalA dataSplitA dataKelasA;

clear jmlTrueKurangB jmlFalseKurangB jmlTrueLebihB jmlFalseLebihB totalLebihB totalKurangB;
clear piTrueKurangB piFalseKurangB piTrueLebihB piFalseLebihB;
clear entropyChildKurangB entropyChildLebihB;
clear iKolomCellB iBarisSplitB iBarisTrainingB;
clear dataAwalB dataSplitB dataKelasB;

clear jumlahDataUniqueTanpaKelas;

clear iFold cvFolds k testIdx vektorCM1;

toc






