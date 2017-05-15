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
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi kolom cell berdasarkan jumlah fitur-1
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
    for iKolomCell = 1 : size(CM1Unique,2)-1 % Iterasi fitur CM1 ada 21 (exclude kelas)
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
            % Penyederhanaan variable "Mtraining02UrutSplit_1" 
            % [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN
            % ----------------------------------------------------------------------------------------------------------------------------                       
        end
                
        % -----------------------------------------------------------------------------------------
        % Mencari nilai best split berdasarkan nilai GAIN tertinggi (max) di Mtraining02UrutSplit_1
        % -----------------------------------------------------------------------------------------
        [Nilai,BarisKe] = max(Mtraining02UrutSplit_1{iFold,iKolomCell}(:,9)); % Ambil urutan ke berapa si split terbaik itu dan ambil nilai max gain-nya
        angkaSplit = Mtraining02UrutSplit_1{iFold, iKolomCell}(BarisKe,1); % Angka split terbaik
        Mtraining03BestSplit_1{iFold,iKolomCell} = [BarisKe angkaSplit Nilai]; % nilai max Gain dari data split ke berapa        
    end  
            
    % ---------------------------------------------------------------------
    % Diskritisasi data numerik (Training) berdasakan best split ( <= , > )
    % ---------------------------------------------------------------------
    for iKolomDiskrit = 1 : size(CM1Unique,2)-1 % 1 : 21
        for iBarisDiskrit = 1 : keteranganCM1(iFold,2) % 1 : jumlah training dari setiap fold            
            % ---------------------------------------------------------------
            % kalau data TRAINING kurang dari sama dengan kriteria EBD ( <= )
            % ---------------------------------------------------------------
            if Mtraining{iFold, iKolomDiskrit}(iBarisDiskrit,1) <= Mtraining03BestSplit_1{iFold,iKolomDiskrit}(1,2)
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 0;
            % --------------------------------------------------------
            % kalau data TRAINING lebih dari kriteria EBD ( > )
            % --------------------------------------------------------
            else                
                Mtraining04Biner_1{iFold,1}(iBarisDiskrit,iKolomDiskrit) = 1;
            end
            % -----------------------------------------------------
            % Menambahkan kolom kelas ke Mtraining04Biner_1
            % -----------------------------------------------------
            if iKolomDiskrit == size(CM1Unique,2)-1 %21              
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
        hasilEBD(iFold,:) = [iFold uniqueTanpaKelas length(Mtraining05UniqueBiner_1{iFold,1})] ; % Perbandingan jumlah unique DENGAN dan TANPA kelas                    
    %---
    
        % --------------------------------
        % Perlu dilakukan split EBD 2 fase
        % --------------------------------               
        for iKolomSplit = 1 : length(Mtraining02UrutSplit_1) % Iterasi kolom, ada 21
            A = 1; % Untuk parameter <=
            B = 1; % Untuk parameter >
            for iDataSplit = 1 : length(Mtraining02UrutSplit_1{iFold,iKolomSplit})-1  % Looping berdasarkan data jumlah split fase pertama dikurangi 1             
                dataPertama = Mtraining02UrutSplit_1{iFold,iKolomSplit}(iDataSplit,1); % Urutan data untuk split pertama
                dataKedua = Mtraining02UrutSplit_1{iFold,iKolomSplit}(iDataSplit+1,1); % Urutan data untuk split kedua
                hasilSplitKedua = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1    
                
                % ----------------------------------------------------------------------------------
                % Cek masuk ke kategori <= atau kategori > berdasarkan MtrainingBestSplit sebelumnya
                % ----------------------------------------------------------------------------------
                splitPertama = Mtraining03BestSplit_1{iFold,iKolomSplit}(1,2); % Ambil nilai split dari fase pertama
                
                if hasilSplitKedua <= splitPertama % Kalau nilai split FASE 2 <= split FASE 1
                    Mtraining02UrutSplit_2A{iFold, iKolomSplit}(A,1) = hasilSplitKedua; % Masuk kategori A
                    A = A + 1;
                else
                    Mtraining02UrutSplit_2B{iFold, iKolomSplit}(B,1) = hasilSplitKedua; % Masuk kategori B
                    B = B + 1;
                end                                  
            end
            
            % ANTISIPASI kalau data di 2B adalah matrix kosong [], misalnya
            % data max GAIN pada fase split pertama berada di paling bawah ( <= ),
            % maka kategori ( > ) tidak ada datanya
            if length(Mtraining02UrutSplit_2B{iFold,iKolomSplit}) == 0
                Mtraining02UrutSplit_2B{iFold,iKolomSplit}(iDataSplit,:) = [0,0,0,0,0,0,0,0,0];
            end
            
        end
                
        % ---------------------------------------------
%1      % Update kolom pada "Mtraining02UrutSplit_2A" :
        % ---------------------------------------------
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
        % -------------------------------------------------------------------------------------------------------
%3      % Konversi data TRAINING menjadi data BINER berdasarkan angka SPLIT TERBAIK di "Mtraining03BestSplit_2A":
        % Nilai BINER disimpan di "Mtraining04Biner_2AB" --> [biner2A,biner2B]
        % -------------------------------------------------------------------------------------------------------
        fase_2A;        
                
        % ---------------------------------------------
%4      % Update kolom pada "Mtraining02UrutSplit_2B" :
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
        % -------------------------------------------------------------------------------------------------------
%6      % Konversi data TRAINING menjadi data BINER berdasarkan angka SPLIT TERBAIK di "Mtraining03BestSplit_2B":
        % Nilai BINER disimpan di "Mtraining04Biner_2AB" --> [biner2A,biner2B]
        % -------------------------------------------------------------------------------------------------------
        fase_2B;        
                                
        
        % --------------------------------------------------------------------
        % Cloning "Mtraining04Biner_1" exclude KELAS ke "Mtraining04Biner_ALL"
        % --------------------------------------------------------------------
        for iKolom = 1 : size(CM1Unique,2)-1 % 1 : 21 [array]
            for iBaris = 1 : keteranganCM1(iFold,2) % banyaknya data training berdasarkan setiap fold                                                                   
                for iKolomData = 1 : size(CM1Unique,2)-1 % 1 : 21 [metrik]                
                    Mtraining04Biner_ALL{iFold,iKolom}(iBaris,iKolomData) = Mtraining04Biner_1{iFold,1}(iBaris, iKolomData);                                     
                end                              
            end
        end
        
        % ----------------------------------------------------------------------------------------
        % Penggabungan biner FASE 1 dengan biner FASE 2 (A dan B), berdasarkan masing-masing fitur
        % ----------------------------------------------------------------------------------------
        totalFitur = size(CM1Unique,2)-1; % 21
        for iKolomArray = 1 : totalFitur % 1 : 21
            for iBarisBiner = 1 : keteranganCM1(iFold,2) % banyaknya data training berdasarkan setiap fold  
                dataA = Mtraining04Biner_2AB{iFold,iKolomArray}(iBarisBiner,1); % Nilai biner A
                dataB = Mtraining04Biner_2AB{iFold,iKolomArray}(iBarisBiner,2); % Nilai biner B                     
                Mtraining04Biner_ALL{iFold,iKolomArray}(iBarisBiner,totalFitur+1) = dataA; % A disimpan di kolom 22
                Mtraining04Biner_ALL{iFold,iKolomArray}(iBarisBiner,totalFitur+2) = dataB; % B disimpan di kolom 23      
                Mtraining04Biner_ALL{iFold,iKolomArray}(iBarisBiner,totalFitur+3) = Mtraining04Biner_1{iFold,1}(iBarisBiner, 22); % KELAS disimpan di kolom 24
                
                % -----------------------------------------------------------------
                % Distinct data "Mtraining04Biner_ALL" (SEMUA fitur TERMASUK kelas)
                % -----------------------------------------------------------------
                Mtraining05UniqueBiner_2{iFold,iKolomArray} = unique(Mtraining04Biner_ALL{iFold,iKolomArray},'rows'); % Data redundan diseleksi (include kelas)               
                
                % ---------------------------------------------------------------------------------------------------------------------------------------
                % Jika masih ada duplikasi pada "Mtraining05UniqueBiner_2" TANPA kelas, maka bisa dipastikan ada duplikasi data dengan kelas yang berbeda
                % ---------------------------------------------------------------------------------------------------------------------------------------                                         
                uniqueBinerAllDenganKelas = length(Mtraining05UniqueBiner_2{iFold,iKolomArray}); % jumlah unique dengan kelasnya juga
                uniqueBinerAllTanpaKelas = length(unique(Mtraining05UniqueBiner_2{iFold,iKolomArray}(:,1:23),'rows')); % Jumlah unique tanpa kelas                
                                    
                if  uniqueBinerAllTanpaKelas ~= uniqueBinerAllDenganKelas % Data unique tanpa kelas ~= data unique
                    hasilEBD_2{iFold,iKolomArray}( 1 ,:) = [uniqueBinerAllTanpaKelas length(Mtraining05UniqueBiner_2{iFold,iKolomArray})] ;                                                           
                end
                
            end
        end
        
        
        
%         % -------------------
%         % Coba-coba duplikasi
%         % -------------------
%         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+1 , : ) = Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1}) , : );
%         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+2 , : ) = Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1}) , : );
%         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+3 , : ) = Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1}) , : );
%         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+1 , 24 ) = 1;
%         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+2 , 24 ) = 0;
%         Mtraining05UniqueBiner_2{iFold,1}( length(Mtraining05UniqueBiner_2{iFold,1})+3 , 24 ) = 1;             

        
        
        % -----------------------------------------------------------
        % Ngambil perbandingan jumlah T dan F dari data yang redundan
        % -----------------------------------------------------------
%         counter = 0;            
%         for iKolomKelas = 1 : size(CM1Unique,2)-1 % 21
%             for iBarisKelas = 1 : length(Mtraining05UniqueBiner_2{iFold,1}) % Data Unique biner                                                            
%                 for iBarisCari = 1 : length(Mtraining04Biner_ALL{iFold,1}) % Data biner                                                                                                
%                     if Mtraining05UniqueBiner_2{iFold,iKolomKelas}(iBarisKelas,:) == Mtraining04Biner_ALL{iFold,iKolomKelas}(iBarisCari,:) % cek tanpa kelas                                                                                                    
%                         counter = counter + 1;                                                       
%                         hasilDuplikasi{iFold,1}(counter,:) = [iFold iBarisKelas iBarisCari];    
%                         %Mtraining05UniqueBiner_2{iFold,1}(iBarisCari,:)
%                     end                                             
%                 end
%             end
%         end
            

        
        
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

clear iBarisDiskrit2A iBarisDiskrit2B iKolomDiskrit2A iKolomDiskrit2B;
clear nilaiSplit2A nilaiSplit2B;

clear dataA dataB iBaris iBarisBiner iBarisCari iBarisKelas counter;
clear iKolom iKolomArray iKolomData uniqueBinerAllDenganKelas uniqueBinerAllTanpaKelas totalFitur;

clear jumlahDataUniqueTanpaKelas;

clear iFold cvFolds k testIdx vektorCM1;

toc