% INPUT:
%--------
% Jumlah FITUR CM1Unique tanpa kelas (21)
% Jumlah BARIS data "Mtraining02UrutSplit_2B" pada FITUR dan FOLD tertentu
% Jumlah BARIS data "Mtraining01Urut" pada setiap FITUR dan FOLD tertentu
% Data "Mtraining01Urut" di setiap FITUR dan FOLD
% Data "Mtraining02UrutSplit_2B" yaitu data split FASE 2 setiap FITUR dan FOLD


        % ----------------------------------------------------------------------------------------------------------
        % Cari jumlah TRUE dan FALSE serta nilai ENTROPY children di Mtraining berdasarkan "Mtraining02UrutSplit_2B"
        % ----------------------------------------------------------------------------------------------------------                        
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
                
                % -----------------------------------------
                % Mencari nilai INFO dari setiap data split
                % -----------------------------------------
                dataChildKurangB = (totalKurangB/keteranganCM1(iFold,2)) * Mtraining02UrutSplit_2B{iFold, iKolomCellB}(iBarisSplitB,4);
                dataChildLebihB = (totalLebihB/keteranganCM1(iFold,2)) * Mtraining02UrutSplit_2B{iFold, iKolomCellB}(iBarisSplitB,7);
                INFOsplitB(iBarisSplitB,1) = (dataChildKurangB + dataChildLebihB);
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,8) = INFOsplitB(iBarisSplitB,1); % nilai INFO dari data SPLIT. disimpan di kolom 8

                % ------------------------------------
                % Mencari nilai GAIN dari setiap INFO
                % ------------------------------------
                GAINinfoB(iBarisSplitB,1) = keteranganCM1(iFold,5) - INFOsplitB(iBarisSplitB,1);
                Mtraining02UrutSplit_2B{iFold,iKolomCellB}(iBarisSplitB,9) = GAINinfoB(iBarisSplitB,1); % nilai INFO dari data SPLIT. disimpan di kolom 9                        

                % ----------------------------------------------------------------------------------------------------------------------------
                % Penyederhanaan variable "Mtraining02UrutSplit_2B" 
                % [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN
                % ----------------------------------------------------------------------------------------------------------------------------                 
            end                    
            % ---------------------------------------------------------------
            % Mencari nilai best split berdasarkan nilai GAIN tertinggi (max)
            % ---------------------------------------------------------------
            [NilaiB,BarisKeB] = max(Mtraining02UrutSplit_2B{iFold,iKolomCellB}(:,9)); % Ambil urutan ke berapa si split terbaik itu dan ambil nilai max gain-nya
            angkaSplitB = Mtraining02UrutSplit_2B{iFold, iKolomCellB}(BarisKeB,1); % Angka split terbaik dari daftar urut split
            Mtraining03BestSplit_2B{iFold,iKolomCellB} = [BarisKeB angkaSplitB NilaiB]; % nilai max Gain dari data split ke berapa                           
        end      
        
        % ----------------------------------------------------------------------------------------
        % Diskritisasi data numerik (Training) berdasakan best split ( <= , > ) pada "BestSplit2B"
        % ----------------------------------------------------------------------------------------
        for iKolomDiskrit2B = 1 : size(CM1Unique,2)-1 % 1 : 21
            for iBarisDiskrit2B = 1 : keteranganCM1(iFold,2) % 1 : jumlah training dari setiap fold                                
                % ----------------------------------------------------------------------
                % kalau data di array metrik kurang dari sama dengan kriteria EBD ( <= )
                % ----------------------------------------------------------------------
                nilaiSplit2B = Mtraining03BestSplit_2B{iFold,iKolomDiskrit2B}(1,2); % Untuk ambil nilai max gain ke berapa
                if Mtraining{iFold, iKolomDiskrit2B}(iBarisDiskrit2B,1) <= nilaiSplit2B 
                    Mtraining04Biner_2AB{iFold,iKolomDiskrit2B}(iBarisDiskrit2B,2) = 0; % Kolom 2 adalah hasil 2B
                % --------------------------------------------------------
                % kalau data di array metrik lebih dari kriteria EBD ( > )
                % --------------------------------------------------------
                else                
                    Mtraining04Biner_2AB{iFold,iKolomDiskrit2B}(iBarisDiskrit2B,2) = 1; % Kolom 2 adalah hasil 2B
                end                                 
            end           
        end
               
% OUTPUT:
% --------
% Entropy children B ( <= ) dan ( > )
% Nilai INFO dari setiap data split di FITUR dan FOLD tertentu
% Nilai GAIN dari setiap INFO di FITUR dan FOLD tertentu
% "Mtraining02UrutSplit_2B" dengan total 9 kolom
% Nilai Gain (MAX) sebagai split terbaik "Mtraining03BestSplit_2B"
% Konversi TRAINING ke data BINER berdasarkan kriteria "Mtraining03BestSplit_2B"
% Hasil akhir adalah "Mtraining04Biner_2AB"        
