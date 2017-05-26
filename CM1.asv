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
k = 10; %length(CM1Unique);
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
            
%==================================================================================================================================
%                                           *********** EBD FASE 1 ***********
%==================================================================================================================================
    
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
    % Menyederhanakan variable "keteranganCM1" (setiap fold)
    % [1] Testing, [2] Training, [3] TRUE, [4] FALSE, [5] Entropy Parent
    % -------------------------------------------------------------------
    keteranganCM1(iFold,:) = [jmlTesting(iFold,:) jmlTraining(iFold,:) jmlTrue(iFold,:) jmlFalse(iFold,:) entropyParent(iFold,:)];
        
    % ------------------------------------------------------------
    % Mengisi data metrik Mtraining dan Mtesting (fitur dan kelas)
    % ------------------------------------------------------------
    for iKolomCell = 1 : 21 % Iterasi kolom cell berdasarkan jumlah fitur (exclude kelas)
        % -------------------------------------------------------------------------------
        % iTraining dan iTesting = nge-set nilai metrik array ke berapa untuk ngisi data 
        % -------------------------------------------------------------------------------
        iTraining = 1; % di Mtraining
        iTesting = 1; % di Mtesting
        for iBarisCM1Unique = 1 : length(CM1Unique) % Looping 1 s.d. 442
            if trainIdx(iBarisCM1Unique,iFold) == 1 % Mengambil urutan CM1Unique berdasarkan trainIdx = 1 [TRAINING]
                dataFitur = CM1Unique(iBarisCM1Unique,iKolomCell); % Data fitur training
                dataKelas = CM1Unique(iBarisCM1Unique,22); % Data kelas training <--- MANUAL ambil kelas
                Mtraining{iFold,iKolomCell}(iTraining,:) = [dataFitur dataKelas]; % Mengisi array metrik[fitur,kelas] untuk Mtraining
                Mtraining01Urut{iFold,iKolomCell} = sortrows(Mtraining{iFold,iKolomCell}); % Diurutkan berdasarkan kolom pertama
                iTraining = iTraining + 1;
            else % Mengambil urutan (trainIdx ~= 1) dengan CM1Unique [TESTING]
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
    for iKolomCell = 1 : 21 % Iterasi fitur CM1 ada 21 (exclude kelas)
        for iDataTraining = 1 : keteranganCM1(iFold, 2)-1 % Looping berdasarkan data jumlah TRAINING dari tabel "keteranganCM1" dikurangi 1
            dataPertama = Mtraining01Urut{iFold,iKolomCell}(iDataTraining,1); % Urutan data untuk split
            dataKedua = Mtraining01Urut{iFold,iKolomCell}(iDataTraining+1,1); % Urutan data untuk split
            Mtraining02UrutSplit_1 {iFold,iKolomCell}(iDataTraining,1) = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1           
        end            
    end    
        
    % -------------------------------------------------------------------------------------------------------
    % Cari jumlah TRUE dan FALSE serta nilai ENTROPY children di Mtraining berdasarkan Mtraining02UrutSplit_1
    % -------------------------------------------------------------------------------------------------------
    jmlTrueKurang = 0;
    jmlFalseKurang = 0;
    jmlTrueLebih = 0;
    jmlFalseLebih = 0;    
    for iKolomCell = 1 : 21 % Iterasi fitur CM1 ada 21 (exclude kelas)
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
            % Penyederhanaan variable "Mtraining02UrutSplit_1" 
            % [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN
            % ----------------------------------------------------------------------------------------------------------------------------                       
        end
              
        % ---------------------------------
        % Distinct "Mtraining02UrutSplit_1"
        % ---------------------------------    
        Mtraining02UrutSplitDistinct_1{iFold,iKolomCell} = unique(Mtraining02UrutSplit_1{iFold,iKolomCell},'rows');    
        
        % -----------------------------------------------------------------------------------------
        % Mencari nilai best split berdasarkan nilai GAIN tertinggi (max) di Mtraining02UrutSplit_1
        % -----------------------------------------------------------------------------------------
        [Nilai,BarisKe] = max(Mtraining02UrutSplitDistinct_1{iFold,iKolomCell}(:,9)); % Ambil urutan ke berapa si split terbaik itu dan ambil nilai max gain-nya
        angkaSplit = Mtraining02UrutSplitDistinct_1{iFold, iKolomCell}(BarisKe,1); % Angka split terbaik
        Mtraining03BestSplit_1{iFold,iKolomCell} = [BarisKe angkaSplit Nilai]; % nilai max Gain dari data split ke berapa        
    end  
            
    % ---------------------------------------------------------------------
    % Diskritisasi data numerik (Training) berdasakan best split ( <= , > )
    % ---------------------------------------------------------------------
    for iKolomDiskrit = 1 : 21 % Iterasi fitur exclude kelas
        for iBarisDiskrit = 1 : keteranganCM1(iFold,2) % 1 : jumlah training dari setiap fold            
            % ---------------------------------------------------------------
            % Kalau data TRAINING kurang dari sama dengan kriteria EBD ( <= )
            % ---------------------------------------------------------------
            if Mtraining{iFold, iKolomDiskrit}(iBarisDiskrit,1) <= Mtraining03BestSplit_1{iFold,iKolomDiskrit}(1,2)
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 0;
            % -------------------------------------------------
            % Kalau data TRAINING lebih dari kriteria EBD ( > )
            % -------------------------------------------------
            else                
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 1;
            end
            % ---------------------------------------------
            % Menambahkan kolom kelas ke Mtraining04Biner_1
            % ---------------------------------------------
            if iKolomDiskrit == 21 %Fitur ke 21              
                dataKelasnya = Mtraining{iFold,iKolomDiskrit}(iBarisDiskrit,2); % ambil data kelas dari Mtraining
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit+1) = dataKelasnya; % data kelas disimpan di kolom ke 22
            end                                    
        end           
    end   
        
    % ----------------------------------------------------------------------
    % Distinct data MtrainingBiner_1 --> agar tidak ada redudansi data biner
    % ----------------------------------------------------------------------
    Mtraining05UniqueBiner_1{iFold,1} = unique(Mtraining04Biner_1{iFold,1},'rows'); % Data redundan diseleksi (include kelas)
    
    % ---------------------------------------------------------------------------------------------------------------------------------------
    % Jika jumlah "Mtraining05UniqueBiner_1" DENGAN dan TANPA kelas itu berbeda, maka dipastikan ada duplikasi data dengan kelas yang berbeda
    % ---------------------------------------------------------------------------------------------------------------------------------------
    uniqueDenganKelas = length(Mtraining05UniqueBiner_1{iFold,1}); % jumlah unique dengan kelasnya juga
    uniqueTanpaKelas = length(unique(Mtraining05UniqueBiner_1{iFold,1}(:,1:21),'rows')); % Data unique tanpa kelas
    if  uniqueTanpaKelas ~= uniqueDenganKelas % Data unique tanpa kelas ~= data unique 
    %---    
        hasilEBD(iFold,:) = [iFold uniqueTanpaKelas length(Mtraining05UniqueBiner_1{iFold,1})] ; % Perbandingan jumlah unique DENGAN dan TANPA kelas                    
        
%==================================================================================================================================
%                                           *********** EBD FASE 2 ***********
%==================================================================================================================================    
    
        % ------------------------------------------------------------------------------------------------------
        % Pembagian data "Mtraining02UrutSplitDistinct_1" berdasarkan "Mtraining03BestSplit_1" menjadi 2A dan 2B
        % ------------------------------------------------------------------------------------------------------
        for ikolomFold = 1 : 21
            A = 1; % Karena counter A dan B berbeda
            B = 1; % Karena counter A dan B berbeda
            jumlahDataDistinct_1 = size(Mtraining02UrutSplitDistinct_1{iFold,ikolomFold},1); 
            for iBarisData = 1 : jumlahDataDistinct_1
                bestSplit_1 = Mtraining03BestSplit_1{iFold,ikolomFold}(1,2);
                dataSplit_1 = Mtraining02UrutSplitDistinct_1{iFold,ikolomFold}(iBarisData,1);
                if dataSplit_1 <= bestSplit_1
                    Mtraining06Urut_2A{iFold,ikolomFold}(A,1) = dataSplit_1;
                    A = A + 1;
                else
                    Mtraining06Urut_2B{iFold,ikolomFold}(B,1) = dataSplit_1;
                    B = B + 1;
                end
            end
        end        
        
        % -------------------------------
        % Split data "Mtraining06Urut_2A"
        % -------------------------------
        for iKolomFold2A = 1 : 21                       
            jumlah2A = size(Mtraining06Urut_2A{iFold,iKolomFold2A},1); % Banyaknya data di "Mtraining06Urut_2A"
            %urutanBestSplit = Mtraining03BestSplit_1{iFold, iKolomFold2A}(1,1); % Urutan ke berapa si best split
            nilaiBestSplit = Mtraining03BestSplit_1{iFold, iKolomFold2A}(1,2); % Nilai best splitnya berapa
            % -----------------------------------
            % Urutan best split 1, ga perlu split
            % -----------------------------------
            if jumlah2A == 1                
                Mtraining07UrutSplit_2A{iFold,iKolomFold2A}(1,1) = nilaiBestSplit;                
            % -----------------------------------------
            % Kalau lebih dari satu datanya, siap split
            % -----------------------------------------
            else
                for iBaris2A = 1 : jumlah2A - 1 % Dikurangi satu                                                                                                
                    % ----------------------------------------
                    % Urutan data yang terakhir tidak di-split
                    % ----------------------------------------
                    dataPertama = Mtraining06Urut_2A{iFold,iKolomFold2A}(iBaris2A,1); % Urutan data split pertama
                    dataKedua = Mtraining06Urut_2A{iFold,iKolomFold2A}(iBaris2A+1,1); % Urutan data split kedua
                    hasilSplit2A = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1                                             
                    Mtraining07UrutSplit_2A{iFold,iKolomFold2A}(iBaris2A,1) = hasilSplit2A;                                        
                end
            end                            
        end
        
        % -------------------------------
        % Split data "Mtraining06Urut_2B"
        % -------------------------------        
        for iKolomFold2B = 1 : 21 
            % -------------------------------------------
            % Antisipasi, kalau "Mtraining06Urut_2B" = []
            % -------------------------------------------
            if size(Mtraining06Urut_2B{iFold,iKolomFold2B},1) ~= 0
            %--                   
                jumlah2B = size(Mtraining06Urut_2B{iFold,iKolomFold2B},1); % Banyaknya data di "Mtraining06Urut_2B"            
                nilai2B = Mtraining06Urut_2B{iFold,iKolomFold2B}(1,1); % Nilai 2B satu-satunya            
                % --------------------------------------------------------
                % Jumlah data ""Mtraining06Urut_2B" cuma 1, ga perlu split
                % --------------------------------------------------------
                if jumlah2B == 1                
                    Mtraining07UrutSplit_2B{iFold,iKolomFold2B}(1,1) = nilai2B;                
                % -----------------------------------------
                % Kalau lebih dari satu datanya, siap split
                % -----------------------------------------
                else
                    for iBaris2B = 1 : jumlah2B - 1 % Dikurangi satu                                                                                                
                        % ----------------------------------------
                        % Urutan data yang terakhir tidak di-split
                        % ----------------------------------------
                        dataPertama = Mtraining06Urut_2B{iFold,iKolomFold2B}(iBaris2B,1); % Urutan data split pertama
                        dataKedua = Mtraining06Urut_2B{iFold,iKolomFold2B}(iBaris2B+1,1); % Urutan data split kedua
                        hasilSplit2B = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1                                             
                        Mtraining07UrutSplit_2B{iFold,iKolomFold2B}(iBaris2B,1) = hasilSplit2B;                                        
                    end
                end                
            %--    
            end                                        
        end     
        
        % -------------------------------------------------------------------------------------------
        % Pembagian data training berdasarkan best split peratama -> Jadi training 2A dan training 2B
        % -------------------------------------------------------------------------------------------
        for iKolomTrain = 1 : 21
            A = 1;
            B = 1;
            for iBarisTrain2A = 1 : keteranganCM1(iFold,2)
                dataHEX = Mtraining{iFold,iKolomTrain}(iBarisTrain2A,1);
                dataBestSplit = Mtraining03BestSplit_1{iFold,iKolomTrain}(1,2);
                dataKelasnya = Mtraining{iFold,iKolomTrain}(iBarisTrain2A,2);
                % ------------------------------------
                % Kalau <= best split maka training 2A
                % ------------------------------------
                if dataHEX <= dataBestSplit
                    Mtraining08Training_2A{iFold,iKolomTrain}(A,:) = [dataHEX dataKelasnya];
                    A = A + 1;
                % ------------------------------------
                % Kalau > best split maka training 2B
                % ------------------------------------
                else
                    Mtraining08Training_2B{iFold,iKolomTrain}(B,:) = [dataHEX dataKelasnya];
                    B = B + 1;
                end
            end
        end
                               
        % -------------------------------------------------------------------
%1      % Update kolom pada "Mtraining07UrutSplit_2A" dengan data training 2A
        % -------------------------------------------------------------------
        % Jumlah TRUE ( <= ) data split FASE 2A          [2] 
        % Jumlah FALSE ( <= ) data split FASE 2A         [3] 
        % Entropy CHILDREN ( <= ) di data split FASE 2A  [4] 
        % Jumlah TRUE ( > ) data split FASE 2A           [5] 
        % Jumlah FALSE ( > ) data split FASE 2A          [6] 
        % Entropy CHILDREN ( > ) di data split FASE 2A   [7] 
        % Nilai INFO dari setiap data split 2A           [8] 
        % Nilai GAIN dari setiap data split 2A           [9]         
        % ------------------------------------------------------------
%2      % Mencari nilai GAIN (max) dari setiap FOLD dan FITUR:
        % "Mtraining03BestSplit_2A" --> [barisKe,angkaSplit,nilaiGain]            
        % ------------------------------------------------------------
        fase_2A;        
 
        % ---------------------------------------------
%4      % Update kolom pada "Mtraining07UrutSplit_2B" :
        % ---------------------------------------------
        % Jumlah TRUE ( <= ) data split FASE 2B          [2] 
        % Jumlah FALSE ( <= ) data split FASE 2B         [3] 
        % Entropy CHILDREN ( <= ) di data split FASE 2B  [4] 
        % Jumlah TRUE ( > ) data split FASE 2B           [5] 
        % Jumlah FALSE ( > ) data split FASE 2B          [6] 
        % Entropy CHILDREN ( > ) di data split FASE 2B   [7] 
        % Nilai INFO dari setiap data split 2B           [8] 
        % Nilai GAIN dari setiap data split 2B           [9]           
        % ------------------------------------------------------------
%5      % Mencari nilai GAIN (max) dari setiap FOLD dan FITUR:
        % "Mtraining03BestSplit_2B" --> [barisKe,angkaSplit,nilaiGain]                                
        % ------------------------------------------------------------
        fase_2B;        
                                        
        % ------------------------------------
        % Hasil BINER dan HEXA dari EBD 2 FASE
        % ------------------------------------
        for iKolomFold = 1 : 21
            for iBaris = 1 : keteranganCM1(iFold,2) % Banyaknya data training
                for iFitur = 1 : 21  
                    
                    trainingSekarang = Mtraining{iFold,iFitur}(iBaris,1);
                    kelasnya = Mtraining{iFold, iFitur}(iBaris,2);                    
                    split1 = Mtraining03BestSplit_1{iFold,iFitur}(1,2);
                    split2A = Mtraining09BestSplit_2A{iFold, iFitur}(1,2);
                    split2B = Mtraining09BestSplit_2B{iFold, iFitur}(1,2);                    
                    
                    % ---------------------------------------------------
                    % apakah kolom yang ingin dituju? (dijadikan 2 digit)
                    % ---------------------------------------------------
                    if iFitur == iKolomFold 
                        if trainingSekarang <= split1 % <= split 1                            
                            if trainingSekarang <= split2A % <= split 2A                                
                                Mtraining10Biner_2{iFold,iKolomFold}{iBaris,iFitur}(:,:) = [0,0];     
                                Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,iFitur) = 0;
                            else % > split 2A                                
                                Mtraining10Biner_2{iFold,iKolomFold}{iBaris,iFitur}(:,:) = [0,1];
                                Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,iFitur) = 1;
                            end                            
                        else % > split 1
                            if trainingSekarang <= split2B % <= split 2B
                                Mtraining10Biner_2{iFold,iKolomFold}{iBaris,iFitur}(:,:) = [1,0];
                                Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,iFitur) = 2;
                            else % > split 2B
                                Mtraining10Biner_2{iFold,iKolomFold}{iBaris,iFitur}(:,:) = [1,1];           
                                Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,iFitur) = 3;
                            end                             
                        end 
                        if iFitur == 21 % nambahin kelas                            
                            Mtraining10Biner_2{iFold,iKolomFold}{iBaris,22} = kelasnya;
                            Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,22) = kelasnya;
                            Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,23) = iBaris;
                        end 
                    else % Bukan fitur yang dituju
                        if trainingSekarang <= split1 % <= split 1
                            Mtraining10Biner_2{iFold,iKolomFold}{iBaris,iFitur} = [0];
                            Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,iFitur) = 0;
                        else % > split 1
                            Mtraining10Biner_2{iFold,iKolomFold}{iBaris,iFitur} = [1];                  
                            Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,iFitur) = 1;
                        end                        
                        if iFitur == 21 % nambahin kelas                            
                            Mtraining10Biner_2{iFold,iKolomFold}{iBaris,22} = kelasnya;
                            Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,22) = kelasnya;
                            Mtraining10Biner_2HEX{iFold,iKolomFold}(iBaris,23) = iBaris;
                        end                        
                    end % iFitur == iKolomFold                    
                end % iFitur                
            end % iBaris                        
            
            % ------------------------------------------------
            % Remove redundansi biner di EBD 2 FASE pake kelas
            % ------------------------------------------------
            Mtraining11UniqueHEX_2{iFold,iKolomFold} = unique(Mtraining10Biner_2HEX{iFold,iKolomFold}(:,1:22),'rows');                      
            
            % ---------------------------------------------------
            % Cari perbandingan Unique HEX dengan dan tanpa kelas
            % ---------------------------------------------------
            uniqueHEXdenganKelas = length(Mtraining11UniqueHEX_2{iFold,iKolomFold}); % jumlah unique dengan kelasnya juga
            uniqueHEXtanpaKelas = length(unique(Mtraining10Biner_2HEX{iFold,iKolomFold}(:,1:21),'rows')); % Data unique tanpa kelas
            if  uniqueHEXdenganKelas ~= uniqueHEXtanpaKelas % Data unique tanpa kelas ~= data unique                 
                hasilEBD_2{iFold,iKolomFold} = [iFold uniqueHEXtanpaKelas uniqueHEXdenganKelas] ;
            end                         
        end %iKolomFold      
        
        % -------------------------------------------
        % Mtraining dibandingkan dengan Mtraining_HEX
        % -------------------------------------------
        for iKolomFold = 1 : 21            
            for iBarisTraining = 1 : keteranganCM1(iFold,2)
                c = 0;
                d = 1;
                e = 1;
                
                for iBarisCek = 1 : keteranganCM1(iFold,2)                          
                    c  = c + 1;
                    
                    dataHEX = Mtraining10Biner_2HEX{iFold,iKolomFold}(iBarisTraining,1:22);
                    dataCek = Mtraining10Biner_2HEX{iFold,iKolomFold}(iBarisCek,1:22);
                    if dataHEX == dataCek                        
                        Mtraining12RedudansiKelas{iFold,iKolomFold}{iBarisTraining,:}(d,:) = [c Mtraining{iFold,iKolomFold}(c,1) Mtraining03BestSplit_1{iFold,iKolomFold}(1,2) Mtraining09BestSplit_2A{iFold,iKolomFold}(1,2) Mtraining09BestSplit_2B{iFold,iKolomFold}(1,2) Mtraining{iFold,iKolomFold}(c,2)] ;
                        d = d + 1;                                                
                    end  
                    
                    dataTrainingNon = Mtraining10Biner_2HEX{iFold,iKolomFold}(iBarisTraining,1:21);
                    dataCekNon = Mtraining10Biner_2HEX{iFold,iKolomFold}(iBarisCek,1:21);
                    if dataTrainingNon == dataCekNon                        
                        Mtraining12RedudansiNonKelas{iFold,iKolomFold}{iBarisTraining,:}(e,:) = [c Mtraining{iFold,iKolomFold}(c,1) Mtraining03BestSplit_1{iFold,iKolomFold}(1,2) Mtraining09BestSplit_2A{iFold,iKolomFold}(1,2) Mtraining09BestSplit_2B{iFold,iKolomFold}(1,2) Mtraining{iFold,iKolomFold}(c,2)]; 
                        e = e + 1;                                                
                    end
                    
                end                                     
            end
        end
        
        
                      
% %         % -------------------
% %         % Coba-coba duplikasi
% %         % -------------------
% %         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+1 , : ) = Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1}) , : );
% %         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+2 , : ) = Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1}) , : );
% %         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+3 , : ) = Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1}) , : );
% %         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+1 , 24 ) = 1;
% %         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+2 , 24 ) = 0;
% %         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+3 , 24 ) = 1;             
%                 
%         % -----------------------------------------------------------
%         % Ngambil perbandingan jumlah T dan F dari data yang redundan
%         % -----------------------------------------------------------
% %         counter = 0;            
% %         for iKolomKelas = 1 : size(CM1Unique,2)-1 % 21
% %             for iBarisKelas = 1 : length(Mtraining05UniqueBiner_2{iFold,1}) % Data Unique biner                                                            
% %                 for iBarisCari = 1 : length(Mtraining04Biner_ALL{iFold,1}) % Data biner                                                                                                
% %                     if Mtraining05UniqueBiner_2{iFold,iKolomKelas}(iBarisKelas,:) == Mtraining04Biner_ALL{iFold,iKolomKelas}(iBarisCari,:) % cek tanpa kelas                                                                                                    
% %                         counter = counter + 1;                                                       
% %                         hasilDuplikasi{iFold,1}(counter,:) = [iFold iBarisKelas iBarisCari];    
% %                         %Mtraining05UniqueBiner_2{iFold,1}(iBarisCari,:)
% %                     end                                             
% %                 end
% %             end
% %         end
            

        
        
    %--- 
    else
%         for iKolomReady = 1 : size(CM1Unique,2) % 22
%             for iBarisReady = 1 : keteranganCM1(iFold,2) % Training 401
%                 for iKolomDataReady = 1 : size(Mtraining05UniqueBiner_1,2)
%                     Mtraining06Ready{iFold,iKolomReady}(iBarisReady,iKolomDataReady) = Mtraining05UniqueBiner_1{iFold,iKolomReady}(iBarisReady,iKolomDataReady);
%                 end                
%             end            
%         end        
        disp(iFold);        
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

clear uniqueDenganKelas uniqueTanpaKelas;

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

clear angkaSplitA angkaSplitB BarisKeA BarisKeB;
clear dataChildKurangA dataChildKurangB dataChildLebihA dataChildLebihB;
clear GAINinfoA GAINinfoB INFOsplitA INFOsplitB NilaiA NilaiB;

clear c d dataCek dataCekNon dataTraining dataTrainingNon e iBarisCek;

clear iBarisDiskrit2A iBarisDiskrit2B iKolomDiskrit2A iKolomDiskrit2B;
clear nilaiSplit2A nilaiSplit2B;

clear dataA dataB iBaris iBarisBiner iBarisCari iBarisKelas counter;
clear iKolom iKolomArray iKolomData uniqueBinerAllDenganKelas uniqueBinerAllTanpaKelas totalFitur;

clear iFitur iKolomFold kelasnya split1 split2A split2B trainingSekarang uniqueHEXdenganKelas uniqueHEXtanpaKelas;

clear bestSplit_1 dataSplit_1 iBarisData ikolomFold jumlahDataDistinct_1;

clear iBaris2A hasilSplit2A iKolomFold2A jumlah2A nilaiBestSplit urutanBestSplit;

clear iBaris2B hasilSplit2B iKolomFold2B jumlah2B nilai2B;

clear Mtraining02UrutSplit_1;

clear dataBestSplit iBarisTrain2A iKolomTrain;

clear dataHEX;

clear dataTrainingA panjangSplit2A panjangTraining2A;
clear dataTrainingB panjangSplit2B panjangTraining2B;

clear jumlahDataUniqueTanpaKelas;

clear iFold cvFolds k testIdx vektorCM1;

toc