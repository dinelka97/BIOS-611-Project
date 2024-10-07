.PHONY: clean
.PHONY: init

clean:
	rm -rf derived_data
	rm -rf figures
	rm -rf predictions
	rm -f report.pdf

init:
	mkdir -p derived_data
	mkdir -p figures
	mkdir -p predictions
	

figures/roc_rf.png derived_data.csv metrics.r
	Rscript metrics.r

