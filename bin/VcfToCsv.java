//usr/bin/env jbang "$0" "$@" ; exit $?
//REPOS jcenter,jfrog-genepi-maven=https://genepi.jfrog.io/artifactory/maven
//DEPS info.picocli:picocli:4.5.0
//DEPS genepi:genepi-io:1.0.12
//DEPS com.github.samtools:htsjdk:2.21.3

import java.io.File;
import java.util.List;
import java.util.Vector;
import java.util.concurrent.Callable;

import genepi.io.table.writer.CsvTableWriter;
import genepi.io.table.writer.ExcelTableWriter;
import genepi.io.table.writer.ITableWriter;
import htsjdk.variant.variantcontext.VariantContext;
import htsjdk.variant.vcf.VCFFileReader;
import picocli.CommandLine;
import picocli.CommandLine.Option;

public class VcfToCsv implements Callable<Integer> {

	@Option(names = "--input", description = "input vcf file", required = true)
	private String input;

	@Option(names = "--output", description = "output file", required = true)
	private String output;

	@Option(names = "--format", description = "output format. xls or csv. default: csv", required = false)
	private String format = "csv";

	@Option(names = "--genotypes", description = "genotypes: GT or DS", required = false)
	private String genotypes = "GT";

	public void setInput(String input) {
		this.input = input;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public void setOutput(String output) {
		this.output = output;
	}

	@Override
	public Integer call() throws Exception {

		assert (input != null);
		assert (output != null);

		VCFFileReader reader = new VCFFileReader(new File(input), false);

		List<String> samples = reader.getFileHeader().getGenotypeSamples();

		List<String> columns = new Vector<String>();
		columns.add("chr");
		columns.add("pos");
		columns.add("ref");
		columns.add("alt");
		columns.add("genotyped");
		columns.add("r2");
		columns.addAll(samples);

		ITableWriter writer = null;

		if (format.equals("xls")) {
			writer = new ExcelTableWriter(output);
		} else {
			writer = new CsvTableWriter(output);
		}

		writer.setColumns(columns.toArray(new String[0]));


		for (VariantContext variant : reader) {
			writer.setString("chr", variant.getContig());
			writer.setInteger("pos", variant.getStart());
			writer.setString("ref",variant.getReference().getBaseString());
			String alt = "";
			for (int i = 0; i < variant.getAlternateAlleles().size(); i++) {
				if (!alt.isEmpty()) {
					alt += " ";
				}
				alt += variant.getAlternateAllele(i);
			}
			writer.setString("alt",alt);

			writer.setString("genotyped", variant.getFilters().toString());
			writer.setString("r2", variant.getAttributeAsString("R2", ""));

			for (String sample: samples) {
				if (genotypes.equals("GT")) {
					writer.setString(sample, variant.getGenotype(sample).getGenotypeString());
				} else if (genotypes.equals("DS")) {
					writer.setString(sample, variant.getGenotype(sample).getAttributeAsString("DS", ""));
				}
			}
			writer.next();
		}

		writer.close();
		reader.close();

		return 0;
	}

	public static void main(String... args) {
		int exitCode = new CommandLine(new VcfToCsv()).execute(args);
		System.exit(exitCode);
	}


}
