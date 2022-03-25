//usr/bin/env jbang "$0" "$@" ; exit $?
//REPOS jcenter,jfrog-genepi-maven=https://genepi.jfrog.io/artifactory/maven/
//DEPS info.picocli:picocli:4.6.1
//DEPS genepi:genepi-io:1.1.1

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.Callable;
import genepi.io.table.writer.CsvTableWriter;
import genepi.io.text.LineReader;
import picocli.CommandLine;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

public class PatternSearch implements Callable<Integer> {

	@Parameters(description = "FASTQ files")
	List<String> input;

	@Option(names = "--output", description = "Summary ", required = true)
	private String output;

	@Option(names = "--pattern", description = "Pattern to search for ", required = true)
	private String pattern;

	public void setOutput(String output) {
		this.output = output;
	}

	public Integer call() throws Exception {

		if (input.size() == 1 && new File(input.get(0)).isDirectory()) {
			int count = 0;
			for (File f : new File(input.get(0)).listFiles()) {
				if (f.getName().endsWith("fastq")) {
					input.add(f.getAbsolutePath());
					System.out.println(count);
					count++;
				}
			}
			System.out.println(count + " files added.");
			input.remove(0);
		}

		String[] splits = pattern.split(",");

		CsvTableWriter writer = new CsvTableWriter(new File(output).getAbsolutePath(), '\t', false);

		String[] columnsWrite = { "name", "count" };
		writer.setColumns(columnsWrite);

		HashMap<String, Integer> map = new HashMap<String, Integer>();

		for (String name : input) {

			LineReader reader = new LineReader(name);
			int count = 0;
			while (reader.next()) {
				String line = reader.get();
				for (String split : splits) {
					if (line.contains(split)) {
						count++;
					}
				}
			}
			writer.setString("name", new File(name).getName());
			writer.setInteger("count", count);
			writer.next();
			reader.close();
			map.put(name, count);
		}

		writer.close();

		return 0;
	}

	public static void main(String... args) {
		int exitCode = new CommandLine(new PatternSearch()).execute(args);
		System.exit(exitCode);
	}

}
