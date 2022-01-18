//usr/bin/env jbang "$0" "$@" ; exit $?
//REPOS jcenter,jfrog-genepi-maven=https://genepi.jfrog.io/artifactory/maven/
//DEPS info.picocli:picocli:4.5.0
//DEPS genepi:genepi-io:1.0.12
//DEPS tech.tablesaw:tablesaw-core:0.38.1

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.Callable;

import genepi.io.table.reader.CsvTableReader;
import genepi.io.table.writer.CsvTableWriter;
import picocli.CommandLine;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

public class MutservePerformance implements Callable<Integer> {

	NumberFormat nf = NumberFormat.getNumberInstance(Locale.ENGLISH);
	DecimalFormat df = (DecimalFormat) nf;

	@Parameters(description = "Mutserve text file")
	private String file;

	@Option(names = "--gold", description = "Gold file ", required = true)
	private String gold;

	@Option(names = "--output", description = "Output file ", required = true)
	private String output;

	public void setOutput(String output) {
		this.output = output;
	}

	public void setGold(String gold) {
		this.gold = gold;
	}


	public Integer call() throws Exception {

		assert (file != null);
		assert (gold != null);
		assert (output != null);

		CsvTableWriter writer = new CsvTableWriter(new File(output).getAbsolutePath(), '\t', false);

		String[] columnsWrite = { "ID", "Precision", "Sensitivity", "Specificity" , "F1-Score", "#FP", " #FN", "FP", "FN"  };
		writer.setColumns(columnsWrite);

		final String pos = "Pos";
		final String sampleId = "ID";

		CsvTableReader inputReader = new CsvTableReader(file, '\t');

		Set<String> ids = new TreeSet<String>();

		while (inputReader.next()) {

			ids.add(inputReader.getString(sampleId));

		}
		inputReader.close();

		// iterate over all samples in fle
		for (String id : ids) {

			Set<Integer> allPos = new TreeSet<Integer>();
			Set<Integer> goldPos = new TreeSet<Integer>();
			Set<Integer> falsePositives = new TreeSet<Integer>();
			Set<Integer> falseNegatives = new TreeSet<Integer>();
			Set<Integer> both = new TreeSet<Integer>();

			CsvTableReader goldReader = new CsvTableReader(gold, '\t');

			while (goldReader.next()) {

				if (goldReader.getString("ID").equals(id)) {

					goldPos.add(goldReader.getInteger(pos));

					allPos.add(goldReader.getInteger(pos));

				}

			}

			CsvTableReader variantReader = new CsvTableReader(file, '\t');

			falsePositives.clear();
			falseNegatives.clear();

			both.clear();
			int truePositiveCount = 0;
			int falsePositiveCount = 0;
			int trueNegativeCount = 0;
			int falseNegativeCount = 0;

			while (variantReader.next()) {

				String idSample = variantReader.getString(sampleId);

				int posSample = variantReader.getInteger(pos);

				if (id.equals(idSample)) {

					// only use PASS Variants
					if (!variantReader.getString("Filter").equals("PASS")) {
						continue;
					}

					// Filter on Exome
					if (!(posSample >= 481 && posSample <= 840) && !(posSample >= 4644 && posSample <= 5025)) {
						continue;
					}

					int position = posSample;

					if (goldPos.contains(position)) {
						goldPos.remove(position);
						truePositiveCount++;
						both.add(position);

					} else {
						falsePositives.add(position);
						falsePositiveCount++;
					}
				}

			}

			for (int j = 481; j <= 840; j++) {

				if (!falsePositives.contains(j) && !both.contains(j)) {

					if (!allPos.contains(j)) {

						trueNegativeCount++;
					}

					else {
						falseNegativeCount++;
						falseNegatives.add(j);
					}
				}
			}

			for (int j = 4644; j <= 5025; j++) {

				if (!falsePositives.contains(j) && !both.contains(j)) {

					if (!allPos.contains(j)) {

						trueNegativeCount++;
					}

					else {
						falseNegativeCount++;
						falseNegatives.add(j);
					}
				}
			}

			variantReader.close();

			double sens = truePositiveCount / (double) (truePositiveCount + falseNegativeCount) * 100;
			double spec = trueNegativeCount / (double) (falsePositiveCount + trueNegativeCount) * 100;
			double prec = truePositiveCount / (double) (truePositiveCount + falsePositiveCount) * 100;

			double f1 =  (2 * prec * sens) / (prec + sens);

			df.setMinimumFractionDigits(2);
			df.setMaximumFractionDigits(3);

			String sensFinal = df.format(sens);
			String specFinal = df.format(spec);
			String precFinal = df.format(prec);
			String f1Final = df.format(f1);

			writer.setString(0, id);
			writer.setString(1, precFinal);
			writer.setString(2, sensFinal);
			writer.setString(3, specFinal);
			writer.setString(4, f1Final);
			writer.setInteger(5, falsePositiveCount);
			writer.setInteger(6, falseNegativeCount);
			writer.setString(7, falsePositives.toString());
			writer.setString(8, falseNegatives.toString());
			writer.next();
		}
		writer.close();
		return 0;
	}

	public static void main(String... args) {
		int exitCode = new CommandLine(new MutservePerformance()).execute(args);
		System.exit(exitCode);
	}

}
