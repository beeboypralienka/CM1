function entropyChildren = entropyChildrenEBD(piTrue,piFalse,iBarisSplit)

% Rumus menghitung entropy parent di tahap EBD dari setiap fold
    
    Log2piTrue(iBarisSplit,1) = log2(piTrue(iBarisSplit,1));
    Log2piFalse(iBarisSplit,1) = log2(piFalse(iBarisSplit,1));
    kaliLogTrue(iBarisSplit,1) = Log2piTrue(iBarisSplit,1) * piTrue(iBarisSplit,1);
    kaliLogFalse(iBarisSplit,1) = Log2piFalse(iBarisSplit,1) * piFalse(iBarisSplit,1);
    entropyChildren(iBarisSplit,1) = abs( kaliLogTrue(iBarisSplit,1) + kaliLogFalse(iBarisSplit,1) );
    
end