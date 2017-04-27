%Tear-down semua variable
clear

%Load file CSV dataset mentah
DatasetCM1 = csvread('D:\Kuliah\S2-ITS\Semester_4\Dataset\CSV format\CM1.csv');

%load file CSV dataset (remove duplicate)
CM1Unique = csvread('D:\Kuliah\S2-ITS\Semester_4\Dataset\CSV format\CM1Unique.csv');
%CM1Unique = unique(DatasetCM1,'rows'); <---- gajadi, karena kolom pertama langsung diurutkan

% for IterasiFiturFold = 1:21                    
    %Fold 1 (1:45)
%     Fold1Fitur = strcat('Fold1Fitur',num2str(IterasiFiturFold)); 
%     Fold1.(Fold1Fitur) = [CM1Unique(1:45,IterasiFiturFold)  CM1Unique(1:45,22)]; %Matrix fitur 1 terhadap kelas
%     Fold1.(Fold1Fitur) = sortrows(Fold1.(Fold1Fitur));    
    
    %Fold 2 (46:89)
%     Fold2Fitur = strcat('Fold2Fitur',num2str(IterasiFiturFold));
%     Fold2.(Fold2Fitur) = [CM1Unique(46:89,IterasiFiturFold)  CM1Unique(46:89,22)]; %Matrix fitur 2 terhadap kelas
%     Fold2.(Fold2Fitur) = sortrows(Fold2.(Fold2Fitur)); 
    
    %Fold 3 (90:133)
%     Fold3Fitur = strcat('Fold3Fitur',num2str(IterasiFiturFold));
%     Fold3.(Fold3Fitur) = [CM1Unique(90:133,IterasiFiturFold)  CM1Unique(90:133,22)]; %Matrix fitur 3 terhadap kelas
%     Fold3.(Fold3Fitur) = sortrows(Fold3.(Fold3Fitur)); 
    
    %Fold 4 (134:177)
%     Fold4Fitur = strcat('Fold4Fitur',num2str(IterasiFiturFold));
%     Fold4.(Fold4Fitur) = [CM1Unique(134:177,IterasiFiturFold)  CM1Unique(134:177,22)]; %Matrix fitur 4 terhadap kelas
%     Fold4.(Fold4Fitur) = sortrows(Fold4.(Fold4Fitur)); 
    
    %Fold 5 (178:221)
%     Fold5Fitur = strcat('Fold5Fitur',num2str(IterasiFiturFold));
%     Fold5.(Fold5Fitur) = [CM1Unique(178:221,IterasiFiturFold)  CM1Unique(178:221,22)]; %Matrix fitur 5 terhadap kelas
%     Fold5.(Fold5Fitur) = sortrows(Fold5.(Fold5Fitur));    
    
    %Fold 6 (222:265)
%     Fold6Fitur = strcat('Fold6Fitur',num2str(IterasiFiturFold));
%     Fold6.(Fold6Fitur) = [CM1Unique(222:265,IterasiFiturFold)  CM1Unique(222:265,22)]; %Matrix fitur 6 terhadap kelas
%     Fold6.(Fold6Fitur) = sortrows(Fold6.(Fold6Fitur));
%     
    %Fold 7 (266:309)
%     Fold7Fitur = strcat('Fold7Fitur',num2str(IterasiFiturFold));    
%     Fold7.(Fold7Fitur) = [CM1Unique(266:309,IterasiFiturFold)  CM1Unique(266:309,22)]; %Matrix fitur 7 terhadap kelas
%     Fold7.(Fold7Fitur) = sortrows(Fold7.(Fold7Fitur)); 
    
    %Fold 8 (310:353)
%     Fold8Fitur = strcat('Fold8Fitur',num2str(IterasiFiturFold));    
%     Fold8.(Fold8Fitur) = [CM1Unique(310:353,IterasiFiturFold)  CM1Unique(310:353,22)]; %Matrix fitur 8 terhadap kelas
%     Fold8.(Fold8Fitur) = sortrows(Fold8.(Fold8Fitur));
    
    %Fold 9 (354:397)
%     Fold9Fitur = strcat('Fold9Fitur',num2str(IterasiFiturFold));    
%     Fold9.(Fold9Fitur) = [CM1Unique(354:397,IterasiFiturFold)  CM1Unique(354:397,22)]; %Matrix fitur 9 terhadap kelas
%     Fold9.(Fold9Fitur) = sortrows(Fold9.(Fold9Fitur)); 
    
    %Fold 10 (398:442)
%    Fold10Fitur = strcat('Fold10Fitur',num2str(IterasiFiturFold));    
%    Fold10.(Fold10Fitur) = [CM1Unique(398:442,IterasiFiturFold)  CM1Unique(398:442,22)]; %Matrix fitur 10 terhadap kelas
%    Fold10.(Fold10Fitur) = sortrows(Fold10.(Fold10Fitur));
%end
%clear Fold1Fitur;   clear Fold2Fitur;   clear Fold3Fitur;   clear Fold4Fitur;   clear Fold5Fitur;
%clear Fold6Fitur;   clear Fold7Fitur;   clear Fold8Fitur;   clear Fold9Fitur;   clear Fold10Fitur;
  

%--------- TESTING FOLD 10 ---------
%JumlahTrue = 0;
%JumlahFalse = 0;

%945
%JumlahIterasiFold1 = length(Fold1.Fold1Fitur1) + length(Fold1.Fold1Fitur2) + length(Fold1.Fold1Fitur3) + length(Fold1.Fold1Fitur4) + length(Fold1.Fold1Fitur5) + length(Fold1.Fold1Fitur6) + length(Fold1.Fold1Fitur7) + length(Fold1.Fold1Fitur8) + length(Fold1.Fold1Fitur9) + length(Fold1.Fold1Fitur10) + length(Fold1.Fold1Fitur11) + length(Fold1.Fold1Fitur12) + length(Fold1.Fold1Fitur13) + length(Fold1.Fold1Fitur14) + length(Fold1.Fold1Fitur15) + length(Fold1.Fold1Fitur16) + length(Fold1.Fold1Fitur17) + length(Fold1.Fold1Fitur18) + length(Fold1.Fold1Fitur19) + length(Fold1.Fold1Fitur20) + length(Fold1.Fold1Fitur21);



%for IterasiHitungJumlahTrueFalse=1:length(Fold1.Fold1Fitur1)
%    if Fold1.Fold1Fitur1(IterasiHitungJumlahTrueFalse,2) == 1
%        JumlahTrue = JumlahTrue + 1;
%    else
%        JumlahFalse = JumlahFalse + 1;
%    end
%end
%TotalTrueFalse = JumlahTrue + JumlahFalse;
%piTrue = JumlahTrue/TotalTrueFalse;
%piFalse = JumlahFalse/TotalTrueFalse;
%Log2PiTrue = log2(piTrue);
%Log2PiFalse = log2(piFalse);
%piLog2PiTrue = piTrue * Log2PiTrue;
%piLog2PiFalse = piFalse * Log2PiFalse;
%EntropyParentFold1 = abs(piLog2PiTrue + piLog2PiFalse);

%for IterasiSplit = 1 : length(Fold1.Fold1Fitur1)-1
%    Split(IterasiSplit,1) = ( Fold1.Fold1Fitur1(IterasiSplit) + ( Fold1.Fold1Fitur1(IterasiSplit)+1 ) ) / 2;    
%end

for x = 1:21
    sementara = strcat('M',num2str(x));    
    kumpulanStruct.(M) = [CM1Unique(398:442,x)  CM1Unique(398:442,22)]; %Matrix fitur 10 terhadap kelas
    kumpulanStruct.(M) = sortrows(kumpulanStruct.(M));
end

k = 10;
vektorCM1 = CM1Unique(:,1);
cvFolds = crossvalind('Kfold', vektorCM1, k);
clear vektorCM1;

for i = 1:k                                  
    testIdx  = (cvFolds == i);                
    trainIdx(:,i) = ~testIdx;    
        
    jumlahTraining(1,i) = 0;
    jumlahTrue(1,i) = 0;
    jumlahFalse(1,i) = 0;
    piTrue(1,i) = 0;
    piFalse(1,i) = 0;
    for iterasi = 1 : length(CM1Unique)
        if trainIdx(iterasi,i) == 1
            jumlahTraining(1,i) = jumlahTraining(1,i) + 1;
            if CM1Unique(iterasi,22) == 1
                jumlahTrue(1,i) = jumlahTrue(1,i) + 1;
            else
                jumlahFalse(1,i) = jumlahFalse(1,i) + 1;
            end
        end        
    end        
    
    piTrue(1,i) = jumlahTrue(1,i)/jumlahTraining(1,i);
    piFalse(1,i) = jumlahFalse(1,i)/jumlahTraining(1,i);
    Log2piTrue(1,i) = log2(piTrue(1,i));
    Log2piFalse(1,i) = log2(piFalse(1,i));
    kaliLogTrue(1,i) = Log2piTrue(1,i) * piTrue(1,i);
    kaliLogFalse(1,i) = Log2piFalse(1,i) * piFalse(1,i);
    entropyParent(1,i) = abs( kaliLogTrue(1,i) + kaliLogFalse(1,i));
    clear piTrue piFalse Log2piTrue Log2piFalse kaliLogFalse kaliLogTrue;
    
    
    
%     for iterasi = 1 : size(jumlahTraining,2)
%         M = cell( jumlahTraining(1,iterasi) , k ) ; %FOLD
%         
%         
%     end
    
%     for iterasi = 1 : k  %iterasi FOLD
%         for iterasi2 = 1 : length(trainIdx) %iterasi baris
%             %M{iterasi2,k} = zeros(442,2);		
%             if trainIdx(iterasi2,i) == 1 %cek training yang nilainya 1
%                 for iterasi3 = 1 : jumlahTraining(1,i) %
%                     for iterasi4 = 1: size(CM1Unique,2) %iterasi kolom
%                         for iterasi5 = 1:2                            
%                             M{iterasi3,k}(iterasi3,iterasi5) = 0;%[CM1Unique(iterasi3,iterasi4) CM1Unique(iterasi3 , 22)];
%                         end                                                
%                     end                
%                 end                                    
%             end
%         end
%     end
    %M{1,1}(1,1)=44;
    
    
    
    
%     for iterasi = 1 : size(trainIdx)
%         M = cell(i,:);
%         for k = 1 : i
%             M{k,i} = [CM1Unique(:,1) CM1Unique(:,22)]
%     end
    
%     for iterasi = 1 : length(trainIdx)
%         if trainIdx(iterasi,i) == 1
%             for iterasi2 = 1 : jumlahTraining(i)-1
% %                 fiturKelas = cell( jumlahTraining(i),i );
%                 for iterasi3 = 1 : 22
%                     %sortFitur(iterasi2,i) = cell[CM1Unique(iterasi,iterasi3) CM1Unique(iterasi,22)];
% %                     fiturKelas{iterasi3} = [CM1Unique(iterasi,iterasi3) CM1Unique(iterasi,22)];
%                 end
%                 
%             end
%                                     
%         end        
%     end
    
    
    
end
  
clear i cvFolds iterasi k testIdx;







