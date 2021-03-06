function T = LakeTemp(V)
% This function returns the temperature of the Lakeshore temp sensor, when
% is provided the voltage read. Assuming excitation of 10uAmp.

    TempTable =[1 1.19872
        2 1.30001
        3 1.40019
        4 1.69964
        5 1.99892
        6 2.40072
        7 2.79779
        8 3.19981
        9 3.69846
        10 4.19314
        11 5.03988
        12 6.04723
        13 7.06470
        14 8.08209
        15 9.10329
        16 10.1295
        17 11.1533
        18 12.1659
        19 13.1719
        20 14.1682
        21 15.1577
        22 16.1405
        23 17.1192
        24 18.0957
        25 19.0765
        26 20.0565
        27 21.0375
        28 21.8285
        29 22.6252
        30 23.2307
        31 23.8380
        32 24.4467
        33 25.0593
        34 25.6662
        35 26.4877
        36 35.2008
        37 28.1268
        38 29.1442
        39 30.1603
        40 32.1821
        41 35.0929 
        42 38.2078 
        43 42.2032 
        44 46.1931 
        45 52.1914
        46 58.1838 
        47 64.1809 
        48 70.1795 
        49 76.1706 
        50 82.1613
        51 88.1605 
        52 94.1537 
        53 100.141 
        54 110.142 
        55 125.123
        56 140.122 
        57 155.110 
        58 170.105 
        59 185.091 
        60 200.084
        61 215.085 
        62 230.078 
        63 245.072 
        64 260.060 
        65 275.071
        66 290.074 
        67 305.059 
        68 315.066 
        69 320.057 
        70 326.337
        71 331.522];

    VolTable = [1.78058
        1.77958
        1.77866
        1.77529
        1.77106
        1.76424
        1.75654
        1.74800
        1.73591
        1.72152
        1.68875
        1.64324
        1.59344
        1.54340
        1.49531
        1.45120
        1.41233
        1.37892
        1.34999
        1.32477
        1.30234
        1.28199
        1.26300
        1.24484
        1.22682
        1.20820
        1.18801
        1.16968
        1.14929
        1.13517
        1.12631
        1.12118
        1.11780
        1.11530
        1.11259
        1.11035
        1.10836
        1.10611
        1.10403
        1.10020 
        1.09491
        1.08995
        1.08358
        1.07726
        1.06769
        1.05801
        1.04818
        1.03816
        1.02798
        1.01760
        1.00702
        0.996267
        0.985338
        0.966705
        0.937969
        0.908344
        0.877994
        0.846990
        0.815452
        0.783401
        0.750882
        0.717967
        0.684670
        0.651035
        0.617029
        0.582760
        0.548291
        0.525159
        0.513607
        0.498231
        0.486998];

    T = interp1(VolTable,TempTable(:,2),V);
end