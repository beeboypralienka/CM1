% Input:
%--------
% Data "Mtraining07UrutSplit_2A" -> Data split 2A
% Data "Mtraining08Training_2A"  -> Data training untuk 2A

        % ----------------------------------------------------------------------------------------------------------
        % Cari jumlah TRUE dan FALSE serta nilai ENTROPY children di Mtraining berdasarkan "Mtraining07UrutSplit_2A"
        % ----------------------------------------------------------------------------------------------------------
        jmlTrueKurangA = 0;
        jmlFalseKurangA = 0;
        jmlTrueLebihA = 0;
        jmlFalseLebihA = 0;    
        for iKolomCellA = 1 : 21 % Iterasi fitur CM1 ada 21 (exclude kelas)                         
        %--      
            panjangSplit2A = length(Mtraining07UrutSplit_2A{iFold,iKolomCellA}); % Setiap DATA SPLIT diulang sebanyak jumlah DATA TRAINING
            panjangTraining2A = size(Mtraining08Training_2A{iFold,iKolomCellA},1); % Iterasi data training AGAR MATCH dengan SATU DATA split
            for iBarisSplitA = 1 : panjangSplit2A  % data SPLIT 2A
                for iBarisTrainingA = 1 : panjangTraining2A % data TRAINING 2A
                    % -----------------------------------------------------------
                    % Hitung jumlah TRUE dan FALSE dari kategoti ( <= ) dan ( > )
                    % -----------------------------------------------------------                            
                    dataTrainingA = Mtraining08Training_2A{iFold, iKolomCellA}(iBarisTrainingA,1); % Data training
                    dataKelasA = Mtraining08Training_2A{iFold, iKolomCellA}(iBarisTrainingA,2); % Data kelas                          
                    dataSplitA = Mtraining07UrutSplit_2A{iFold, iKolomCellA}(iBarisSplitA,1); % Data split                                        
                    if dataTrainingA <= dataSplitA % ada berapa data training yang ( <= ) data split                                            
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
                % ---------------------------
                % Update kolom 2, 3, 5, dan 6
                % ---------------------------
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,2) = jmlTrueKurangA; % Jumlah TRUE dengan parameter ( <= ) disimpan di kolom 2
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,3) = jmlFalseKurangA; % Jumlah FALSE dengan parameter ( <= ) disimpan di kolom 3
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,5) = jmlTrueLebihA; % Jumlah TRUE dengan parameter ( > ) disimpan di kolom 5
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,6) = jmlFalseLebihA; % Jumlah FALSE dengan parameter ( > ) disimpan di kolom 6                                

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
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,4) = entropyChildKurangA(iBarisSplitA,1); % Nilai entropy child dari parameter ( <= ) disimpan di kolom 4                          

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
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,7) = entropyChildLebihA(iBarisSplitA,1); % Nilai entropy child dari parameter ( > ) disimpan di kolom 7 

                % ----------------------------------------------------------------------
                % Di-NOL-kan, karena jumlah TRUE dan FALSE setiap data split itu berbeda
                % ----------------------------------------------------------------------                
                jmlTrueKurangA = 0;
                jmlFalseKurangA = 0;
                jmlTrueLebihA = 0;
                jmlFalseLebihA = 0;    

                % -----------------------------------------
                % Mencari nilai INFO dari setiap data split
                % -----------------------------------------
                dataChildKurangA = (totalKurangA/keteranganCM1(iFold,2)) * Mtraining07UrutSplit_2A{iFold, iKolomCellA}(iBarisSplitA,4);
                dataChildLebihA = (totalLebihA/keteranganCM1(iFold,2)) * Mtraining07UrutSplit_2A{iFold, iKolomCellA}(iBarisSplitA,7);
                INFOsplitA(iBarisSplitA,1) = (dataChildKurangA + dataChildLebihA);
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,8) = INFOsplitA(iBarisSplitA,1); % nilai INFO dari data SPLIT. disimpan di kolom 8

                % ------------------------------------
                % Mencari nilai GAIN dari setiap INFO
                % ------------------------------------
                GAINinfoA(iBarisSplitA,1) = keteranganCM1(iFold,5) - INFOsplitA(iBarisSplitA,1);
                Mtraining07UrutSplit_2A{iFold,iKolomCellA}(iBarisSplitA,9) = GAINinfoA(iBarisSplitA,1); % nilai INFO dari data SPLIT. disimpan di kolom 9                        

                % ----------------------------------------------------------------------------------------------------------------------------
                % Penyederhanaan variable "Mtraining07UrutSplit_2A" 
                % [1] Data Split, [2] TRUE(<=), [3] FALSE(<=), [4] entropy(<=), [5] TRUE(>), [6] FALSE(>), [7] entropy(>), [8] INFO, [9] GAIN
                % ----------------------------------------------------------------------------------------------------------------------------                
            end     
            % ---------------------------------------------------------------
            % Mencari nilai best split berdasarkan nilai GAIN tertinggi (max)
            % ---------------------------------------------------------------
            [NilaiA,BarisKeA] = max(Mtraining07UrutSplit_2A{iFold,iKolomCellA}(:,9)); % Ambil urutan ke berapa si split terbaik itu dan ambil nilai max gain-nya
            angkaSplitA = Mtraining07UrutSplit_2A{iFold, iKolomCellA}(BarisKeA,1); % Angka split terbaik dari daftar urut split
            Mtraining09BestSplit_2A{iFold,iKolomCellA} = [BarisKeA angkaSplitA NilaiA]; % nilai max Gain dari data split ke berapa                
        %--
        end        
        
% Output:
% --------
% Entropy children A ( <= ) dan ( > )
% Nilai INFO dari setiap data split di FITUR dan FOLD tertentu
% Nilai GAIN dari setiap INFO di FITUR dan FOLD tertentu
% "Mtraining07UrutSplit_2A" dengan total 9 kolom
% Nilai Gain (MAX) sebagai split terbaik "Mtraining09BestSplit_2A"
