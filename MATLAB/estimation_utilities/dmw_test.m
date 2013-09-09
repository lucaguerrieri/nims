function [DMW, GWp, sigma] = dmw_test(out_of_sample_errors_model1,...
                                      out_of_sample_errors_model2,...
                                      qn,sl)

DeltaL_oos = out_of_sample_errors_model1.^2-...
             out_of_sample_errors_model2.^2;


sigma = sqrt(nw(DeltaL_oos,qn));


DMW  = sqrt(size(DeltaL_oos,1))*mean( DeltaL_oos)/sigma;
    GWp = 1-cdf('chi2',DMW^2,1);
    if (GWp>sl)
        GWp = 0;
    else
        GWp = 1;
    end