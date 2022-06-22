//usr/bin/env jbang "$0" "$@" ; exit $?
//REPOS jcenter,jfrog-genepi-maven=https://genepi.jfrog.io/artifactory/maven/
//DEPS info.picocli:picocli:4.6.1
//DEPS genepi:genepi-io:1.1.1

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.concurrent.Callable;
import genepi.io.text.LineReader;
import genepi.io.text.LineWriter;
import picocli.CommandLine;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

public class PatternSearch implements Callable<Integer> {

	private static final String NON_KIV2B_HG37 = "chr6\t161033963\t161054783\tLPA_422_6;LPA_421_3\nchr6\t161056056\t161066618\tLPA_422_2+100bp;LPA_421_1+580bp";

	private static final String KIV2B_HG37 = "chr6\t161033785\t161066618";

	private static final String NON_KIV2B_HG38 = "chr6\t160612931\t160633751\tLPA_422_6;LPA_421_3\n"
			+ "chr6	160635024	160645586	LPA_422_2+100bp;LPA_421_1+580bp";

	// coordinates taken from UKBB download
	private static final String KIV2B_HG38 = "chr6\t160612753\t160645586";

	@Parameters(description = "FASTQ files")
	String input;

	@Option(names = "--output", description = "Summary ", required = true)
	private String output;

	@Option(names = "--output-bed", description = "Summary ", required = true)
	private String outputBed;

	@Option(names = "--pattern", description = "Pattern to search for ", required = true)
	private String pattern;

	@Option(names = "--build", description = "hg19/hg38 ", required = true)
	private String build;

	public void setOutput(String output) {
		this.output = output;
	}

	public Integer call() throws Exception {

		String[] splits = pattern.split(",");

		LineWriter writer = new LineWriter(new File(output).getAbsolutePath());

		LineReader reader = new LineReader(input);
		int count = 0;
		while (reader.next()) {
			String line = reader.get();
			for (String split : splits) {
				if (line.contains(split)) {
					count++;
				}
			}
		}

		writer.write(new File(input).getName() + "\t" + count + "\n");
		reader.close();

		StringBuilder stringBuilder = new StringBuilder();

		if (count > 100) {
			if (build.equals("hg19")) {
				stringBuilder.append(KIV2B_HG37);
			} else {
				stringBuilder.append(KIV2B_HG38);
			}
		} else {
			if (build.equals("hg19")) {
				stringBuilder.append(NON_KIV2B_HG37);
			} else {
				stringBuilder.append(NON_KIV2B_HG38);
			}
		}

		BufferedWriter writerBed = new BufferedWriter(new FileWriter(outputBed));
		writerBed.write(stringBuilder.toString());
		writerBed.close();

		writer.close();

		return 0;
	}

	public static void main(String... args) {
		int exitCode = new CommandLine(new PatternSearch()).execute(args);
		System.exit(exitCode);
	}

}
