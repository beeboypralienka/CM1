%Tear-down semua variable
clear

%Load file CSV dataset mentah
DatasetCM1 = csvread('CM1.csv');

%load file CSV dataset (remove duplicate)
CM1Unique = csvread('CM1Unique.csv');

for IterasiFiturFold = 1:21                    
    % FOLD1(1:45) (46:89) (90:133) (134:177) (178:221) (222:265) (266:309) (310:353) (354:397) (398:442)
    Fold1Fitur = strcat('Fold1Fitur',num2str(IterasiFiturFold)); 
    Fold1.(Fold1Fitur) = [CM1Unique(1:45,IterasiFiturFold)  CM1Unique(1:45,22)]; %Matrix fitur 1 terhadap kelas
    Fold1.(Fold1Fitur) = sortrows(Fold1.(Fold1Fitur));                                       
end
clear Fold1Fitur IterasiFiturFold;  

% Pembagian fold = 10
k = 10;
vektorCM1 = CM1Unique(:,1);
cvFolds = crossvalind('Kfold', vektorCM1, k);
clear vektorCM1;

% Iterasi fold
for i = 1:k    
    
    % Pembagian data training dan testing per setiap fold
    testIdx  = (cvFolds == i);                
    trainIdx(:,i) = ~testIdx;    
        
    
    jumlahTraining(:,i) = 0;
    jumlahTrue(:,i) = 0;
    jumlahFalse(:,i) = 0;
    piTrue(:,i) = 0;
    piFalse(:,i) = 0;
    % Menghitung jumlah training 
    for iterasi = 1 : length(CM1Unique)
        for iterasi2 = 1 : size(CM1Unique,2)                            
            if trainIdx(iterasi,i) == 1
                jumlahTraining(iterasi2,i) = jumlahTraining(iterasi2,i) + 1;
                if CM1Unique(iterasi,22) == 1
                    jumlahTrue(iterasi2,i) = jumlahTrue(iterasi2,i) + 1;
                else
                    jumlahFalse(iterasi2,i) = jumlahFalse(iterasi2,i) + 1;
                end
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







