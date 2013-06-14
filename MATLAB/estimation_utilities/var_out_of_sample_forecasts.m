function [xi] = var_out_of_sample_forecasts(f, var_data, varlag, nfactors, nothers, forecast_horizon)

nstates = nfactors+nothers;

xi = zeros((nstates*varlag)+1,forecast_horizon+1);

for i_index = 1:varlag
xi(1+(i_index-1)*nstates:i_index*nstates,1) = var_data(end-(i_index-1),:)';
end

xi(end,1) = 1;

for i_index = 1:forecast_horizon
    xi(:,i_index+1) = f*xi(:,i_index);
end
xi = xi(:,2:end);


