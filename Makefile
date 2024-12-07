.PHONY: clean
.PHONY: init

clean:
	rm -rf derived_data
	rm -rf figures
	rm -rf predictions
	rm -f report.pdf
	rm -f report.html

init:
	mkdir -p derived_data
	mkdir -p figures
	mkdir -p predictions
	
derived_data/df_pproc.rds derived_data/df_remout.rds: src_data/train.csv clean.r
	Rscript clean.r
	
derived_data/df_colLabel.csv figures/dist_numeric.png figures/dist_factor.png figures/outliers.png: \
derived_data/df_pproc.rds data_summary.r
	Rscript data_summary.r
	
figures/pca_scree.png figures/pc1_pc2.png figures/pca_scree_rem_outliers.png figures/pc1_pc2_rem_outliers.png: \
derived_data/df_pproc.rds derived_data/df_remout.rds eda.r
	Rscript eda.r
	
figures/tsne.png figures/tsne_rem_outliers.png: derived_data/df_pproc.rds derived_data/df_remout.rds eda.r
	Rscript eda.r
	
run_shiny: loan_approval_prediction/rf_trained_model.RData loan_approval_prediction/app.r
	Rscript -e "shiny::runApp('loan_approval_prediction/app.r')"
	
report_dinelka.html: derived_data/df_colLabel.csv figures/dist_numeric.png report_dinelka.Rmd
	Rscript -e "rmarkdown::render('report_dinelka.Rmd',output_format='html_document')"
