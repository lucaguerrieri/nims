function table = run_rs_tests(out_of_sample_errors_model1,out_of_sample_errors_model2,...
                              in_sample_errors_model1,in_sample_errors_model2,...
                              qn,m)
   
    
    DeltaL_oos = out_of_sample_errors_model1.^2-out_of_sample_errors_model2.^2;
    DeltaL_in = in_sample_errors_model1.^2 - in_sample_errors_model2.^2;

    sigma = sqrt(nw(DeltaL_oos,qn));


    DMW  = sqrt(size(DeltaL_oos,1))*mean( DeltaL_oos)/sigma;
    GWp = 1-cdf('chi2',DMW^2,1);
    if (GWp>0.1)
        GWp = 0;
    else
        GWp = 1;
    end

    results = abc(DeltaL_oos, DeltaL_in, m, qn);
    stats = results.stats;
    rej = results.rej;

    
    
    table = [DMW  GWp; stats(1,1) rej(1,1); stats(1,2) rej(1,2); stats(1,3) rej(1,3)];
