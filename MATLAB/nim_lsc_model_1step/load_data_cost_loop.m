
% to do:
% update path for interest rates 


clear

move_deposit_share_down = 1;

setpath
% from NIM_VAR_TINY_DATA.xls
% 1987q1 to 2012q1
% STFBNI_MA_N.Q	STFBAI_MA_N.Q	STFBLDT_XEOP_XDO_MA_N.Q	STFBLDNS_XEOP_XDO_MA_N.Q	STFBLD_XEOP_MA_N.Q	STFBEIDT_XDO_MA_N.Q	STFBEIDNS_XDO_MA_N.Q	STFBLIDT_XQA_XDO_MA_N.Q	STFBLIDNS_XQA_XDO_MA_N.Q

rochelle_varlist = char('assets_securities_notrading','assets_securities_trading','assets_loans_realestate',...
                        'assets_loans_commercial','assets_loans_consumer','assets_loans_other','assets_other',...
                        'revenue_securities_notrading','revenue_securities_trading','revenue_loans_realestate',...
                        'revenue_loans_commercial','revenue_loans_consumer','revenue_loans_other','revenue_other',...
                        'expenses_total');

nassets = 7;                    
rochelle_data = xlsread('interestbearing_assets_revenues_expenses_allcategories_updated.xls');


rochelle_dates = 1985:.25:2012.5;

% ensure that rochelle_data has the same start as all other data needed in
% the VAR
startpos = find(1987 == rochelle_dates);
endpos = find(2012.5 == rochelle_dates);
% luca changed this -- check with Val
rochelle_data = rochelle_data(startpos:endpos,:);

nvars_rochelle = size(rochelle_varlist,1);
for thisvar = 1:nvars_rochelle
    eval([rochelle_varlist(thisvar,:),'=rochelle_data(:,thisvar);'])
end

tiny_varlist = char('STFBNI','STFBAI','STFBLDT','STFBLDNS','STFBLD','STFBEIDT','STFBEIDNS','STFBLIDT','STFBLIDNS');

tiny_dates = 1987:.25:2012.5;

tiny_data=[24018	2556935	611906	545584	2231638	1992	6920	198587	539568
24615	2554670	621709	539989	2254553	2069	6989	178516	542699
25213	2582481	602755	533973	2256433	2120	7174	177503	538322
25972	2622064	641163	531548	2324992	2176	7329	182212	532748
25385	2660765	604212	542228	2308097	2181	7167	186825	535070
25874	2691847	628041	546747	2345436	2237	7274	189739	542270
26740	2718968	617443	537174	2363747	2299	7641	191343	543655
29827	2741210	658068	537314	2419906	2359	7851	194406	539975
27960	2766355	612309	524001	2416492	2346	7866	197214	527063
28027	2807581	619060	509158	2439362	2326	8036	192787	510744
27664	2841387	606650	519846	2454172	2323	8036	191176	515349
28283	2877978	664243	539352	2534727	2377	8234	196643	531306
28274	2916043	617161	553281	2529649	2399	8103	202712	544222
28534	2947626	628021	557781	2574208	2438	8276	205157	551990
29039	2974844	617595	565760	2588412	2469	8447	203109	562615
29529	2976308	680354	574260	2632496	2471	8481	207929	569869
29547	2973324	610581	596467	2594009	2433	8006	214767	582831
30157	2988608	639001	613759	2614570	2455	7845	221232	605120
31023	3005535	668309	630159	2652836	2495	7955	227454	623486
31411	3022962	703345	657459	2673679	2385	7487	238705	645596
32344	3036108	694804	695431	2661595	1967	6313	252044	678699
32933	3049904	709942	706731	2640313	1860	6081	258077	703379
33883	3067218	716154	725384	2629109	1660	5550	262018	720432
34768	3095641	806207	743033	2682891	1572	5122	277690	741590
34477	3108950	748431	749625	2639441	1520	4920	287400	746620
34605	3140857	780771	756408	2664458	1464	4753	290307	757227
35066	3191338	794683	761104	2680338	1444	4737	293578	764714
34947	3260220	850289	769501	2738149	1388	4554	302529	772227
35052	3312555	819027	783294	2740488	1343	4491	303895	778233
36386	3338229	813578	768865	2749012	1364	4771	302895	776822
37081	3374365	808219	754471	2774294	1400	5083	299156	765289
37666	3437313	847674	734940	2854143	1470	5401	299360	749340
37539	3504982	792774	713427	2842629	1512	5566	296965	723861
38228	3571470	803333	720360	2886579	1474	5758	285289	713879
39060	3646743	773799	744964	2910182	1387	5889	270693	731550
39593	3715272	821290	774411	3005845	1336	6032	256900	753242
39744	3759081	749292	826418	3003765	1190	6014	237335	789417
40116	3790884	755624	835301	3038949	1082	6034	220228	816237
41271	3841259	764553	850651	3073645	1019	6300	198051	842386
42259	3918610	793041	881522	3174868	971	6529	181789	876514
41968	3999916	741233	918197	3172792	928	6512	174057	903815
43468	4081718	757041	929559	3258104	919	6780	165426	928758
43910	4173636	712981	957479	3283256	903	6959	157052	946615
44182	4266489	756987	995751	3398984	915	7155	156563	981370
43897	4358321	727085	1046604	3444287	913	7201	160262	1017836
44998	4431325	736833	1064291	3482897	914	7424	157934	1048984
45942	4485792	688255	1098853	3482298	896	7707	151284	1084524
46432	4591082	746305	1178201	3654939	842	7504	153751	1132697
46773	4663143	684943	1200916	3612330	779	7189	153340	1183918
47182	4691315	687307	1222105	3654451	769	7322	152185	1209652
48231	4738670	653137	1249041	3681329	767	7658	144830	1238329
49367	4843987	679327	1256898	3803158	808	8184	151851	1240269
49466	4982507	662257	1302249	3849312	829	8399	153706	1258521
50365	5100319	657662	1309041	3945001	842	8944	151196	1293620
50718	5205122	621447	1353190	3991160	882	9744	143500	1317425
50934	5304114	670438	1414172	4147559	912	10284	145601	1359850
51158	5393223	630968	1499102	4155691	878	10045	152068	1418278
52515	5442295	645951	1543768	4211947	822	8960	155304	1483767
53868	5510603	643652	1611643	4261686	773	8097	155145	1549312
57905	5567451	738849	1706643	4353174	576	6188	161071	1641055
57025	5563427	639295	1804401	4302382	440	5090	163431	1718531
57340	5640276	643009	1852104	4395537	444	5328	161684	1804608
57944	5799155	666228	1944040	4502830	436	5390	161386	1882049
58516	5932056	700999	2021691	4649883	419	4959	167043	1989278
57875	6055777	692384	2117214	4738362	361	4274	170004	2038680
58365	6222423	730875	2208615	4889074	352	4190	178431	2123761
58595	6316007	688359	2246498	4879457	316	3644	184477	2214008
60212	6364170	720778	2298782	4990467	328	3815	191349	2252039
60545	6563874	714101	2400957	5141557	329	3818	196405	2310864
62040	6793214	719032	2472660	5287403	325	3957	206912	2401328
63431	6946847	703569	2522323	5358525	401	4452	204008	2482912
64084	7082538	743863	2568187	5544390	511	5281	210465	2536359
64800	7255659	727335	2621198	5653016	586	6236	213439	2563767
65367	7390589	741387	2619569	5739221	706	7376	204140	2575481
67163	7533082	699321	2697058	5860176	756	8679	196333	2623874
66710	7663790	735086	2746167	6014892	823	9983	198461	2669416
69032	7854355	715840	2770199	6157188	808	11419	201459	2684341
71153	8099156	712374	2764504	6323027	906	12922	201773	2702787
71463	8275989	662780	2763779	6367169	946	14304	192301	2698846
74934	8517321	703661	2897940	6673099	1055	15699	194226	2794926
73040	8687630	687408	2908496	6663895	1022	15252	201155	2811736
74931	8886914	667703	2924344	6805668	911	16037	198835	2854556
78777	9122997	618794	2950300	6948187	1088	16528	183417	2888401
79550	9400567	695072	2994611	7246418	931	15662	191456	2912314
81212	9649048	690189	3104295	7370400	748	12365	199889	2965673
82474	9718325	675694	3097760	7358389	541	8822	202867	3023910
83629	9894340	721768	3178502	7711772	538	8546	194331	3029375
91301	10227564	839083	3293477	8015206	475	7956	195461	3176519
88259	10275464	769823	3457200	7917778	310	4889	203264	3376207
89350	10162140	828651	3521280	8013319	351	4389	225181	3481538
88806	10131851	810271	3668593	8114155	345	4290	234294	3575252
94124	10114256	892031	3879314	8269643	366	4267	252440	3776880
99253	10242865	825770	4039444	8230686	331	3788	253095	3909866
97914	10321499	846906	4072850	8188273	314	3687	249631	4048045
97412	10330834	855131	4199080	8317929	285	3567	241069	4060794
96159	10407824	951799	4333952	8460624	284	3392	272266	4260346
95778	10456197	981982	4449725	8620909	261	3125	282656	4369943
95755	10608832	1072142	4639074	8799109	261	2973	284415	4487334
94879	10757303	1179910	4826551	9019876	239	2543	296622	4714511
96880	10888952	1288464	4981530	9200175	230	2525	316121	4863173
97388	11059758	1239178	5156037	9325894	214	2449	326159	5020107
96109	11192579	1256992	5205862	9387062	215	2369	331789	5123890
96447	11335285	1284526	5357281	9562820	210	2292	330916	5227479];

nvars = size(tiny_varlist,1);

for i = 1:nvars
    eval([tiny_varlist(i,:),'=tiny_data(:,i);'])
    
end


expenses =[39994	33563	4204	1897	250
39494	33195	3966	1981	272
38790	31993	4018	2407	284
38922	31967	4402	2170	290
38688	31449	4373	2462	314
36253	30061	4010	1795	318
34657	28835	3740	1714	316
33903	27709	3844	1916	366
34216	27415	3817	2584	334
35739	28282	3896	3112	383
36470	29116	4057	2852	377
38622	30880	4154	3196	321
38473	30552	4189	3296	370
39507	31066	4444	3580	350
42828	33384	4989	4007	379
45593	35363	5343	4442	393
47555	36638	5966	4475	412
51629	39910	6371	4866	429
52495	40176	6252	5568	442
53356	40702	6308	5859	433
52880	39971	5874	6528	441
50253	39998	5723	4048	423
50959	40787	5796	3878	439
50761	40683	5352	4226	447
45774	37599	4176	3396	548
42303	35259	3698	2802	490
41171	34212	3512	2900	501
39240	32340	3065	3260	526
34095	27992	2608	3008	443
31517	25507	2442	3100	424
29415	23788	2079	2999	511
27499	21500	2134	3332	492
26469	20465	2031	3425	512
25823	19744	2058	3457	523
26712	19737	2178	4196	561
26578	19524	2176	4285	555
25314	18164	2277	4278	558
27674	19237	2874	4934	595
27022	19673	3352	3356	608
30820	22014	3972	4109	689
34470	24411	4457	4805	759
36985	26345	4690	5126	789
37938	27088	4636	5396	782
38537	27410	4637	5616	838
37468	26827	4297	5491	820
36533	26200	4153	5320	827
37251	26700	4101	5485	928
38921	27712	4228	6012	933
38536	27418	4981	5168	968
40400	28777	4878	5792	953
41703	29921	4989	5754	1038
43549	30825	5560	6106	1058
43851	30813	5690	6143	1204
44057	30925	5354	6666	1112
45802	32028	5654	6891	1229
44333	31363	5474	6285	1211
42398	29541	5141	6539	1178
41664	28998	5095	6413	1158
42979	29460	5153	7125	1241
48202	31841	5816	9234	1310
49684	33530	6120	8718	1316
54223	36460	6770	9563	1430
58140	39521	6911	10181	1527
59844	41477	7040	9720	1608
57087	39619	6380	9559	1528
50536	35534	5434	8169	1398
45723	32318	4712	7315	1378
35361	24803	3055	6286	1217
29816	20817	2455	5443	1101
31141	21442	2545	6047	1107
30258	20840	2516	5788	1115
27496	18577	2403	5391	1125
25281	16906	2158	5145	1073
24523	16247	2094	5125	1058
22642	15056	1761	4771	1054
21660	14173	1579	4867	1040
22374	14542	1794	4951	1087
22935	14686	2032	5113	1104
25657	16339	2527	5575	1217
27557	18063	2489	5538	1467
32920	21191	3559	6707	1463
37395	24232	4144	7422	1597
43276	28301	5232	8075	1668
48900	32192	6226	8586	1896
54432	35856	7139	9488	1950
61409	40939	8187	10174	2109
68145	46146	8984	10799	2216
78941	50680	9538	16393	2329
72975	50128	9319	11256	2272
76556	52116	9778	12319	2343
80412	55206	9625	13069	2512
80156	55116	8949	13613	2478
68753	47013	6918	12439	2384
55319	37709	5199	10455	1956
53227	36219	4939	10335	1734
49227	33339	2699	10963	2227
34028	23956	1284	7202	1586
32047	22196	1033	7300	1518
28359	19726	1006	6326	1301
25761	17150	761	6603	1247
23861	15301	666	6848	1046
22646	14557	665	6403	1020
21308	13753	513	5898	1143
21100	13114	1247	5727	1012
19135	12092	823	5211	1009
18885	12048	862	5059	916
16988	11015	581	4500	893
15973	10069	559	4460	885
15176	9507	543	4193	933
14430	9126	532	3904	867
13569	8733	514	3516	806
];


liabilities =[1815950	1544495	188792	68799	10880
1852314	1572742	192551	72144	11942
1887555	1591921	200264	79858	12604
1940369	1620897	213137	89617	13764
1987924	1653388	225040	91601	14984
2007390	1668410	227555	92882	15728
2035211	1686231	229476	100456	16262
2087296	1722447	240188	105176	16668
2126340	1756245	246429	103832	17068
2143678	1777578	235982	110150	17250
2171667	1796165	231421	124026	17307
2209618	1828502	236281	124673	17439
2254303	1860033	244288	129821	17461
2286277	1877528	247005	141772	17257
2312800	1899190	245182	148678	17033
2337228	1928611	241295	147675	16864
2366155	1959899	246737	139743	16918
2408386	1981837	261424	144810	17432
2440084	2000038	266908	151947	18481
2474208	2034222	272591	145654	19391
2515125	2073906	276943	142493	19590
2553113	2110409	273715	147206	19578
2577545	2137714	266272	152032	19342
2571572	2147675	254679	145624	21413
2566993	2162099	243126	135744	23848
2586620	2179676	240224	140515	24063
2597879	2182536	239920	149136	24235
2605688	2192954	236116	150049	24577
2601412	2194129	239184	141315	24851
2592009	2175680	238505	149774	26111
2587524	2150723	238975	167118	28726
2592975	2146973	250230	162006	31817
2599801	2148293	259842	155920	33878
2617521	2145337	263227	171576	35477
2641686	2141818	267916	193285	36742
2683509	2157944	275134	211634	36956
2718159	2181327	280092	217899	37096
2751544	2200891	290259	221660	37145
2788563	2220459	297911	230853	37838
2847961	2260186	306270	240489	39505
2910927	2301539	313746	253527	40609
2959608	2322060	317655	277019	41340
3010116	2342724	322215	300823	42787
3050575	2377598	325017	303048	43405
3083440	2418838	320629	298255	44204
3115019	2437979	313568	315373	46367
3147118	2443169	310114	344069	47930
3204272	2482499	313478	356838	49618
3270742	2531189	352428	334654	51520
3335095	2569666	384516	327894	53019
3417456	2625149	393411	344560	54337
3506855	2695011	409592	344044	58208
3584485	2754282	416770	349816	63617
3641546	2792909	404017	378498	66122
3685430	2815771	400356	401857	67447
3778554	2885521	422266	400584	70183
3862973	2944867	435282	410384	72440
3901063	2950124	440253	437345	73342
3949751	2975819	430201	469218	74513
4066433	3050512	428371	512110	75440
4193766	3125244	454206	537268	77048
4292780	3187030	471063	554758	79930
4381288	3259211	464002	575360	82715
4455763	3345754	461444	563435	85130
4533733	3417893	480649	547052	88139
4579117	3450665	498891	540147	89414
4616375	3476288	520162	529546	90379
4631529	3487391	515254	535648	93235
4609191	3494425	498316	522956	93494
4661154	3539521	505715	523214	92704
4763172	3595413	517141	558020	92599
4859859	3665231	541036	560480	93112
4961896	3758731	562942	545820	94402
5073241	3834999	588528	554052	95662
5156951	3894662	572422	592914	96953
5227169	3961034	522667	645385	98083
5368059	4066324	532799	670213	98722
5554019	4180820	571886	700613	100699
5702670	4271261	597315	730939	103156
5770646	4379056	579548	705680	106362
5881803	4501659	569306	699207	111631
5987184	4559170	595594	718381	114040
6104807	4635340	624057	730114	115296
6236207	4750865	636513	729798	119031
6410071	4904889	653407	727924	123851
6639312	5065287	697095	747833	129096
6831369	5180167	750413	766880	133909
7041624	5347001	736790	815416	142418
7170860	5452484	716302	850602	151472
7367816	5563834	742819	903937	157225
7634211	5721919	739893	1008739	163660
7924961	5925440	737042	1091988	170491
8171929	6105059	771904	1120668	174297
8269411	6145192	804945	1145393	173882
8464845	6216006	832755	1242432	173652
8746320	6449841	820826	1297567	178086
8702423	6536754	774822	1215496	175352
8520719	6508163	752706	1093031	166819
8427430	6589792	722554	953297	161788
8356269	6676861	620047	903198	156162
8446996	6700047	548140	1047877	150931
8479865	6661500	548111	1122162	148093
8394359	6660389	546798	1038737	148435
8362037	6718332	538373	958843	146489
8327891	6795795	505332	885481	141283
8327879	6851825	479286	859215	137554
8284623	6876432	467393	804912	135885
8237005	6903020	449602	751285	133097
8299347	6993969	436862	738501	130015
8367077	7070525	459063	715302	122187
8386496	7105045	467952	699917	113582
];

liabilities = liabilities(9:end,:);
expenses = expenses(9:end,:);

expenses_labels = char('expenses_total','expenses_deposits','expenses_ffunds','expenses_treasury','expenses_notes');
liabilities_labels = char('liabilities_total','liabilities_deposits','liabilities_ffunds','liabilities_treasury','liabilities_notes');

nexpenses = size(expenses_labels,1);

for i = 1:nexpenses
   eval([expenses_labels(i,:),'=expenses(:,i);'])
   eval([liabilities_labels(i,:),'=liabilities(:,i);']) 
end

figure
plot_type=char('k-','r--','b:','g-.');
for i=2:nexpenses
    
    plot(tiny_dates',liabilities(:,i)./liabilities(:,1),plot_type(i-1,:))
    hold on
 
end 
legend(liabilities_labels(2:end,:));

figure
plot_type=char('k-','r--','b:','g-.');
for i=2:nexpenses
    
    plot(tiny_dates',expenses(:,i)./liabilities(:,i),plot_type(i-1,:))
    hold on
 
end 
legend(expenses_labels(2:end,:));



% expenses_other = expenses_total;
% liabilities_other = liabilities_total;
% 
% for i=2:nexpenses
%     eval(['expenses_other = expenses_other -',expenses_labels(i,:)])
%     eval(['liabilities_other = liabilities_other -',liabilities_labels(i,:)])
% end
% 
% expenses_labels = strvcat(expenses_labels,'expenses_other');
% liabilities_labels = strvcat(liabilities_labels,'liabilities_other');



% TO DO -- get RG10 and RTB

RG10 =[
    1985       11.624548       10.916302       10.482159        9.953211
    1986        8.794895        7.919041        7.736377        7.612916
    1987        7.416962        8.473714        8.958818        9.213693
    1988        8.589162        9.037095        9.211639        9.043693
    1989        9.279549        8.860077        8.206185        8.026316
    1990        8.523523        8.764437        8.790836        8.48628
    1991        8.159308        8.283963        8.10156         7.537817
    1992        7.528283        7.548562        6.921729        7.005035
    1993        6.530642        6.213549        5.792892        5.7783
    1994        6.235513        7.190991        7.416452        7.896851
    1995        7.571749        6.699469        6.452551        6.001209
    1996        6.034212        6.825228        6.828449        6.420202
    1997        6.633498        6.788396        6.362967        6.027861
    1998        5.736409        5.759236        5.368647        4.945752
    1999        5.353873        5.843707        6.236318        6.474795
    2000        6.670422        6.428826        6.115367        5.771675
    2001        5.300727        5.503141        5.256979        5.060168
    2002        5.38828         5.354969        4.545092        4.293955
    2003        4.159475        3.804543        4.403814        4.435445
    2004        4.143326        4.749978        4.445861        4.3016
    2005        4.391728        4.23583         4.289392        4.595725
    2006        4.669545        5.150624        4.962649        4.699268
    2007        4.756282        4.919887        4.84199         4.409248
    2008        3.867428        4.090844        4.050319        3.722935
    2009        3.229115        3.650376        3.811927        3.685286
    2010        3.865567        3.617287        2.897102        2.966173
    2011        3.528548        3.276287        2.483641        2.093935
    2012        2.063211        1.9             1.8             nan];

RTB =[
    1985        8.16875         7.476           7.106364        7.165455
    1986        6.899531        6.138923        5.527879        5.353485
    1987        5.535           5.656615        6.03803         5.864545
    1988        5.722615        6.214615        7.015           7.732462
    1989        8.544615        8.402923        7.845077        7.653692
    1990        7.758769        7.746462        7.479846        6.996515
    1991        6.030781        5.558154        5.382121        4.546515
    1992        3.893538        3.680769        3.084545        3.071364
    1993        2.960156        2.966769        3.003333        3.060606
    1994        3.25125         3.991385        4.478939        5.285077
    1995        5.735538        5.596154        5.367692        5.261846
    1996        4.932154        5.017846        5.097576        4.976061
    1997        5.059844        5.048462        5.045303        5.087727
    1998        5.052187        4.976308        4.824242        4.25303
    1999        4.407188        4.452615        4.65            5.048485
    2000        5.525231        5.716154        6.018923        6.020462
    2001        4.819846        3.658769        3.189231        1.913788
    2002        1.720938        1.717385        1.644091        1.338636
    2003        1.156875        1.041846        0.929242        0.916061
    2004        0.916615        1.077538        1.486667        2.013182
    2005        2.542969        2.864615        3.363333        3.828462
    2006        4.394           4.706769        4.908308        4.904154
    2007        4.981846        4.736462        4.314462        3.403636
    2008        2.065077        1.623077        1.49197         0.301515
    2009        0.210625        0.173231        0.156818        0.056667
    2010        0.107969        0.146462        0.156667        0.136818
    2011        0.125781        0.046462        0.02303         0.013231
    2012        0.066308        0.04            0.02             nan];


%% construct variables of interest:
NIM = STFBNI*4./STFBAI*100;

core_deposit_share = 100*(STFBLDT+STFBLDNS)./STFBLD;
core_deposit_rate = 400*(STFBEIDT+STFBEIDNS)./(STFBLIDT+STFBLIDNS);

RG10 = RG10(:,2:5);
RG10 = reshape(RG10',length(RG10(:)),1);
RG10 = RG10(9:end-1);


RTB = RTB(:,2:5);
RTB = reshape(RTB',length(RTB(:)),1);
RTB = RTB(9:end-1);


assets_total_tmp = sum(rochelle_data(:,1:nassets),2);
revenue_total_tmp = sum(rochelle_data(:,nassets+1:nassets*2),2);

assets_total = STFBAI;
revenue_total = STFBNI+expenses_total;

% redefine to ensure adding up to total
assets_other = assets_other + STFBAI-assets_total_tmp;
revenue_other = revenue_other+(STFBNI+expenses_total)-revenue_total_tmp;


for thisvar=1:nassets
    eval([deblank(rochelle_varlist(thisvar,:)),'_share = ',rochelle_varlist(thisvar,:),'./assets_total;'])
end

% next, loop through revenue categories
% to construct "baby" NIM
for thisvar = nassets+1:2*nassets
    eval(['nim',deblank(rochelle_varlist(thisvar,8:end)),...
        ' = (',rochelle_varlist(thisvar,:),'./',rochelle_varlist(thisvar-nassets,:),'-expenses_total./assets_total)*400;'])
end




% % check relationship between the aggregate of baby NIMs and the original
% % NIM measure.
% 
% NIM_aggregate = 0*NIM;
% for this_asset = 1:nassets
%     this_str =num2str(this_asset);
%     eval([' NIM_aggregate= NIM_aggregate+',deblank(rochelle_varlist(this_asset,:)),'_share.*nim_',deblank(rochelle_varlist(this_asset,8:end)),';']);
% end
% 
% NIM_aggregate_share = 0*NIM;
% for this_asset = 1:nassets
%     this_str =num2str(this_asset);
%     eval([' NIM_aggregate_share= NIM_aggregate_share+',deblank(rochelle_varlist(this_asset,:)),'_share;']);
% end
% 
% revenue_aggregate = 0*NIM;
% for this_asset = 1:nassets
%     this_str =num2str(this_asset);
%     eval([' revenue_aggregate= revenue_aggregate+',deblank(rochelle_varlist(this_asset+nassets,:)),';']);
% end

% figure
% plot(tiny_dates,[nim_loans_commercial nim_loans_consumer nim_loans_other nim_loans_realestate nim_securities_notrading nim_securities_trading nim_other])
% title('Disaggragate NIMS (AR, unweighted)')
% legend('Loans, commercial','Loans, consumer','Loans, other','Loans, real estate','Securities, no trading','Securities, trading','Other')
% ylabel('Percent')
% xlim([tiny_dates(1) tiny_dates(end)])
% 
% figure
% plot(tiny_dates,100*[assets_loans_commercial_share assets_loans_consumer_share assets_loans_other_share assets_loans_realestate_share assets_securities_notrading_share assets_securities_trading_share assets_other_share])
% title('Shares of Interest Bearing Assets (AR, unweighted)')
% legend('Loans, commercial','Loans, consumer','Loans, other','Loans, real estate','Securities, no trading','Securities, trading','Other')
% ylabel('Percent')
% xlim([tiny_dates(1) tiny_dates(end)])


% liabilities
nliabilities = size(liabilities,2)-1;
for i =1:nliabilities
    eval([deblank(liabilities_labels(i+1,:)),'_share = liabilities(:,i+1)./liabilities(:,1);'])
    eval(['expenses',num2str(i),'=liabilities_total./assets_total.*expenses(:,i+1)./liabilities(:,i+1)*400;'])
end

revenue1 = revenue_total./assets_total*400;



if move_deposit_share_down
liabilities_deposits_share(end) = liabilities_deposits_share(end)-.1;
liabilities_ffunds_share(end) = liabilities_ffunds_share(end)+.05;
liabilities_treasury_share(end) = liabilities_treasury_share(end)+.05;
end

%%
var_dates = tiny_dates;

var_data = [NIM core_deposit_rate RTB RG10];

%optlag=biclag(var_data,1,25); 

%varlag = 2; 
varlag = 4;

startpos = 1;
nvars= size(var_data,2);
nobs =size(var_data,1);
varlagmat = varlag*ones(nvars);
isconstant = 1;
iscontemp = 0;

% create list of components of expenses
partlist = char('');
for i=1:nliabilities
    partlist = strvcat(partlist,['expenses',num2str(i)]);
end

% add total revenue last
partlist = strvcat(partlist,'revenue1');

nparts = size(partlist,1);
endpos = find(var_dates == 2008.5);


for this_var =1:nparts
    this_str = num2str(this_var);
    eval(['var_data_',this_str,' = [',partlist(this_var,:),' core_deposit_rate RTB RG10];'])
    
    eval(['[coefs_',this_str,',coverr_',this_str,',errmat_',this_str,']=estimate(varlagmat,zeros(nvars),ones(nvars,1),var_data_',this_str,'(1:endpos,:));'])
    
    eval(['[cofb_',this_str,',const_',this_str,']=ols2ar(coefs_',this_str,'(1:end,:),isconstant,iscontemp);'])
    
    
    % Express the VAR in companion form
    eval(['cofcompanion_',this_str,' = companion(cofb_',this_str,',const_',this_str,');'])
    
    
    % change this move away from last observation in the VAR -- VAR data
    % ends before last observation.
    xi10 = [var_data(end,:)]';
    
    eval(['xi10_',this_str,' = transpose([var_data_',this_str,'(end,:)])']);
    
    for lag_num=1:varlag-1
        eval(['xi10_',this_str,' = [xi10_',this_str,'; transpose(var_data_',this_str,'(end-lag_num,:))];'])
    end;
    
    eval(['xi10_',this_str,' = [xi10_',this_str,'; 1];'])
    
    %NB:  q is the Cholesky of Q in Hamilton's notation
    eval(['q_',this_str,' = zeros(length(xi10_',this_str,'));'])
    eval(['q_',this_str,'(1:nvars,1:nvars) = transpose(chol(coverr_',this_str,'));'])
    
end




%%
% The coding of the Kalman filter recursions follows Hamilton's "Time
% Series Analysis," see section 13.2 on page 377.

% !f is the transition matrix for the hidden state
% !h relates the observable state to the hidden state
% !y holds the observed data
% !x10 is the initial prior on the initial state vector
% !q is the variance covariance matrix on error term in the hidden state


%1 is for the constant





ntrain = 0;

% this is the variance covariance matrix for the initial state.
% I am setting this to zero, equivalent to saying that we know the
% initial state with certainty.
P10 = 0.000000000001*eye(size(q_1,1));




%% What follows are columns g and h from the excel files from 2012q2 till the last observation
% the first col is RTB; the second is RG10

% baseline
y_baseline = [0.086769231	1.8260547
    0.1	1.85
    0.100000287	1.799999998
    0.100000286	1.899999984
    0.100000137	2.099999959
    0.199999847	2.299999913
    0.199999516	2.499999899
    0.193126141	2.871874987
    0.250210978	3.103124998
    0.319690312	3.315625006
    0.4	3.50937501
    0.524859276	3.6375
    0.693481326	3.8125
    0.940362712	3.9875
    1.3	4.1625];

% bear_flattener
y_bear_flattener = [0.086769231	1.8260547
    0.500037294	1.952662778
    0.824947713	1.954024064
    1.224012187	2.119384947
    1.423392686	2.345827718
    1.795175275	2.622134169
    1.99411976	2.878377195
    2.190006664	3.33730222
    2.246908903	3.613276053
    2.316125676	3.883203411
    2.495641854	4.140903718
    2.619902152	4.313560526
    2.787680894	4.558570792
    3.033292135	4.785244622
    3.391049642	5.015758262
    ];

%bear_parallel
y_bear_parallel = [0.086769231	1.8260547
    0.500037294	2.265285512
    0.824947713	2.62255477
    1.224012187	3.376969966
    1.423392686	4.063045177
    1.795175275	4.479764042
    1.99411976	4.864127072
    2.190006664	5.434260217
    2.246908903	5.693092816
    2.316125676	5.928731612
    2.495641854	6.209417475
    2.619902152	6.345496039
    2.787680894	6.543044526
    3.033292135	6.729647617
    3.391049642	6.924273943
    ];

% bear steepener
y_bear_steepener = [0.086769231	1.8260547
    0.1	2.270594062
    0.100000287	2.620240738
    0.100000286	3.104131188
    0.100000137	3.679280502
    0.199999847	4.147823669
    0.199999516	4.513564974
    0.193126141	5.05538294
    0.250210978	5.463275046
    0.319690312	5.854597044
    0.4	6.177853116
    0.524859276	6.440398819
    0.693481326	6.699458244
    0.940362712	6.961931531
    1.3	7.278346234
    ];

% bull flattener
y_bull_flattener=[0.086769231	1.8260547
    0.1	1.690591609
    0.100000287	1.445329397
    0.100000286	1.347205142
    0.100000137	1.317020877
    0.199999847	1.283817525
    0.199999516	1.254370752
    0.193126141	1.361634306
    0.250210978	1.365184638
    0.319690312	1.523082317
    0.4	1.658532416
    0.524859276	1.773623483
    0.693481326	1.93580629
    0.940362712	2.235979824
    1.3	2.521014362];

%% reset the observation equation to pick out RTB and RG10 in the state vector


h = zeros(2,size(cofcompanion_1,1));
% select position of RTB in the state vector -- N.B: RTB is the fifth
% variable
% h has as many rows as observed variables and as many columns as the
% number of state variables (NIM core_deposits 3monthrate 10yearrate)
h(1,3) = 1;
h(2,4) = 1;


yw = 0;

% to do -- expand to include two loops
% an inner loop for the 6 models
% and an outer loop for all the replication
T = size(errmat_1,1);

nreps = 100;

scenario_list = char('baseline','bear_flattener','bear_parallel','bear_steepener','bull_flattener')
nscenarios = size(scenario_list,1);

symmetric_confint_switch =1;
% baseline point forecast
for this_scenario =1:nscenarios
    scenario_str = deblank(scenario_list(this_scenario,:));
for this_asset = 1:nparts
    % [logLikel,errcode,xi10History,xi1tHistory_baseline,errHistory] = ...
    %     kalmanFilterSmoother(cofcompanion, h', y_baseline', xi10, P10, q, ntrain);
    this_str =num2str(this_asset);
    eval(['[logLikel,errcode,xi10History,xi1tHistory_',deblank(scenario_str),'_',this_str,',errHistory]',...
        '= kalmanFilterSmoother(cofcompanion_',this_str,', transpose(h), transpose(y_',deblank(scenario_str),'),',...
        ' xi10_',this_str,', P10, q_',this_str,', ntrain);'])
    
end

eval(['xi1tHistory_',deblank(scenario_str),' = 0*xi1tHistory_baseline_1;'])

% in partlist, expenses are listed first. Last comes total revenue
for this_asset = 1:nparts
    this_str =num2str(this_asset);
    
    if this_asset<nparts
    eval([' xi1tHistory_',deblank(scenario_str),' = xi1tHistory_',deblank(scenario_str),'-',deblank(liabilities_labels(this_asset+1,:)),'_share(end)*xi1tHistory_',deblank(scenario_str),'_',this_str,';']);
    else  % make exception for revenues
    eval([' xi1tHistory_',deblank(scenario_str),' = xi1tHistory_',deblank(scenario_str),'+','xi1tHistory_',deblank(scenario_str),'_',this_str,';']);    
    end
    
end

replication = zeros(nreps,size(y_baseline,1));
for this_rep = 1:nreps
    % to block bootstrap, keep the replications constant across models
    errpos = round((T-1)*rand(T,1)+ones(T,1));
    
    for this_asset =1:nparts
        this_str = num2str(this_asset);
        %[replication] = ...
        %    confint_partial(cofb,const,errmat,var_data(1:end-14,:),varlag,nreps,isconstant,...
        %            iscontemp,yw,h,y_baseline,xi10,P10,q,ntrain,errpos);
        
        eval(['[replication_',this_str,'] = confint_partial(cofb_',this_str,',const_',this_str,',errmat_',this_str,',var_data_',this_str,'(1:endpos,:),varlag,nreps,isconstant,iscontemp,yw,h,y_',deblank(scenario_str),',xi10_',this_str,',P10,q_',this_str,',ntrain,errpos);']);
        
        if this_asset<nparts
        eval(['replication(this_rep,:) = replication(this_rep,:) - replication_',this_str,'*',deblank(liabilities_labels(this_asset+1,:)),'_share(end);'])
        else
        eval(['replication(this_rep,:) = replication(this_rep,:) + replication_',this_str,';'])
        end
    end
    
end

if ~symmetric_confint_switch
replication = sort(replication);
eval(['confint_lb_',scenario_str,' = replication(round(nreps/100*5),:);'])
eval(['confint_ub_',scenario_str,' = replication(round(nreps/100*95),:);'])
else
std_vec =std(replication);
eval(['confint_lb_',scenario_str,' = xi1tHistory_',scenario_str,'(1,:)-2*std_vec;'])
eval(['confint_ub_',scenario_str,' = xi1tHistory_',scenario_str,'(1,:)+2*std_vec;'])    
end
end
% 
% figure
% plot(xi1tHistory_baseline(1,:),'k')
% hold on
% plot(confint_lb_baseline,'r--')
% plot(confint_ub_baseline,'r--')

% % bear flattener
% [logLikel,errcode,xi10History,xi1tHistory_bear_flattener,errHistory] = ...
%     kalmanFilterSmoother(cofcompanion, h', y_bear_flattener', xi10, P10, q, ntrain);
%
% [confint_lb_bear_flattener confint_ub_bear_flattener] = ...
%     confint(90,cofb,const,errmat,var_data(1:end-14,:),varlag,nreps,isconstant,...
%             iscontemp,yw,h,y_bear_flattener,xi10,P10,q,ntrain);
%
% % bear parallel
% [logLikel,errcode,xi10History,xi1tHistory_bear_parallel,errHistory] = ...
%     kalmanFilterSmoother(cofcompanion, h', y_bear_parallel', xi10, P10, q, ntrain);
%
% [confint_lb_bear_parallel confint_ub_bear_parallel] = ...
%     confint(90,cofb,const,errmat,var_data(1:end-14,:),varlag,nreps,isconstant,...
%                          iscontemp,yw,h,y_bear_parallel,xi10,P10,q,ntrain);
%
% % bear steepener
% [logLikel,errcode,xi10History,xi1tHistory_bear_steepener,errHistory] = ...
%     kalmanFilterSmoother(cofcompanion, h', y_bear_steepener', xi10, P10, q, ntrain);
%
% [confint_lb_bear_steepener confint_ub_bear_steepener] = ...
%     confint(90,cofb,const,errmat,var_data(1:end-14,:),varlag,nreps,isconstant,...
%                          iscontemp,yw,h,y_bear_steepener,xi10,P10,q,ntrain);
%
% % bull steepener
% [logLikel,errcode,xi10History,xi1tHistory_bull_flattener,errHistory] = ...
%     kalmanFilterSmoother(cofcompanion, h', y_bull_flattener', xi10, P10, q, ntrain);
%
% [confint_lb_bull_flattener confint_ub_bull_flattener] = ...
%     confint(90,cofb,const,errmat,var_data(1:end-14,:),varlag,nreps,isconstant,...
%                          iscontemp,yw,h,y_bull_flattener,xi10,P10,q,ntrain);
%
%
% %%
%
figure
subplot(2,2,1)
plot(xi1tHistory_bear_flattener(1,:),'k')
hold on
plot(confint_lb_bear_flattener,'b--')
plot(confint_ub_bear_flattener,'b--')
title('Bear Flattener')

subplot(2,2,2)
plot(xi1tHistory_bear_parallel(1,:),'k')
hold on
plot(confint_lb_bear_parallel,'b--')
plot(confint_ub_bear_parallel,'b--')
title('Bear Parallel')

subplot(2,2,3)
plot(xi1tHistory_bear_steepener(1,:),'k')
hold on
plot(confint_lb_bear_steepener,'b--')
plot(confint_ub_bear_steepener,'b--')
title('Bear Steepener')

subplot(2,2,4)
plot(xi1tHistory_bull_flattener(1,:),'k')
hold on
plot(confint_lb_bull_flattener,'b--')
plot(confint_ub_bull_flattener,'b--')
title('Bull Flattener')


%
figure
forecast_dates = 2012.25:.25:2015.75;

plot(forecast_dates,xi1tHistory_baseline(1,1:end),'k-')
hold on
plot(forecast_dates,xi1tHistory_bear_flattener(1,1:end),'r:')
plot(forecast_dates,xi1tHistory_bear_parallel(1,1:end),'b.')
plot(forecast_dates,xi1tHistory_bear_steepener(1,1:end),'g--')
plot(forecast_dates,xi1tHistory_bull_flattener(1,1:end),'k-.')

legend('Baseline','Bear Flattener','Bear Parallel','Bear Steepener','Bull Flattener')

figure
subplot(2,2,1)
plot(forecast_dates',y_bear_flattener(:,1),'k'); hold on
plot(forecast_dates',y_bear_flattener(:,2),'r-')
legend('RTB', 'RG10','Location','NorthWest')
title('Bear Flattener')

subplot(2,2,2)
plot(forecast_dates',y_bear_parallel(:,1),'k'); hold on
plot(forecast_dates',y_bear_parallel(:,2),'r-')
legend('RTB', 'RG10','Location','NorthWest')
title('Bear Parallel')

subplot(2,2,3)
plot(forecast_dates',y_bear_steepener(:,1),'k'); hold on
plot(forecast_dates',y_bear_steepener(:,2),'r-')
legend('RTB', 'RG10','Location','NorthWest')
title('Bear Steepener')

subplot(2,2,4)
plot(forecast_dates',y_bull_flattener(:,1),'k'); hold on
plot(forecast_dates',y_bull_flattener(:,2),'r-')
legend('RTB', 'RG10','Location','NorthWest')
title('Bull Flattener')