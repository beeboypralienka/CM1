function entropyParent = entropyParentEBD(jmlTrue,jmlFalse,jmlTraining,i)

% Rumus menghitung entropy parent di tahap EBD dari setiap fold
for iFold = 1 : i
    piTrue(iFold,1) = jmlTrue(iFold,1)/jmlTraining(iFold,1);
    piFalse(iFold,1) = jmlFalse(iFold,1)/jmlTraining(iFold,1);
    Log2piTrue(iFold,1) = log2(piTrue(iFold,1));
    Log2piFalse(iFold,1) = log2(piFalse(iFold,1));
    kaliLogTrue(iFold,1) = Log2piTrue(iFold,1) * piTrue(iFold,1);
    kaliLogFalse(iFold,1) = Log2piFalse(iFold,1) * piFalse(iFold,1);
    entropyParent(iFold,1) = abs( kaliLogTrue(iFold,1) + kaliLogFalse(iFold,1) );        
end