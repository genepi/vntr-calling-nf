
//usr/bin/env jbang "$0" "$@" ; exit $?
//REPOS jcenter,jfrog-genepi-maven=https://genepi.i-med.ac.at/maven/
//DEPS info.picocli:picocli:4.6.1
//DEPS genepi:genepi-io:1.1.1
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PushbackInputStream;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.Callable;
import java.util.TreeMap;
import java.util.zip.GZIPInputStream;

import genepi.io.table.writer.CsvTableWriter;
import picocli.CommandLine;
import picocli.CommandLine.Option;

public class FastaUtil implements Callable<Integer> {

	@Option(names = "--input", description = "Input MSA file", required = true)
	private String input;

	@Option(names = "--output", description = "PSV file", required = true)
	private String output;

	public Integer call() throws Exception {

		try {
			File file = new File(input);
			CsvTableWriter writer = new CsvTableWriter(new File(output).getAbsolutePath(), '\t', false);
			String[] columnsWrite = { "Position", "NumberOfRepeatsIncluded" };
			writer.setColumns(columnsWrite);

			Map<String, String> map = readAsMap(file.toPath());

			List<String[]> fastaList = new ArrayList<String[]>();
			int size = 0;

			for (Entry<String, String> entry : map.entrySet()) {
				fastaList.add(entry.getValue().split(""));
				size = entry.getValue().split("").length;
			}

			TreeMap<Integer, Integer> result = new TreeMap<Integer, Integer>();
			int shiftsInReference = 0;
			double psvsTotal = 0;

			for (int j = 0; j < size; j++) {

				String latest = "";
				boolean reported = false;
				int numberOfRepeatsIncluded = 0;

				for (int i = 0; i < fastaList.size(); i++) {

					String currentEntry = fastaList.get(i)[j];

					if (!latest.equals("") && !latest.equals(currentEntry)) {

						if (fastaList.get(fastaList.size() - 1)[j].equals("-")) {
							shiftsInReference++;
						}
						if (!reported) {
							result.put(j + 1 - shiftsInReference, ++numberOfRepeatsIncluded);
							reported = true;
							psvsTotal++;
						} else {
							result.put(j + 1 - shiftsInReference, ++numberOfRepeatsIncluded);
						}
					}
					latest = currentEntry;
				}

			}

			System.out.println(psvsTotal / size * 100 + "%");

			for (Entry<Integer, Integer> a : result.entrySet()) {
				writer.setInteger(0, a.getKey());
				writer.setInteger(1, a.getValue());
				writer.next();
			}
			writer.close();
			
		} catch (IOException e) {
			e.printStackTrace();
		}

		return 0;

	}

	public static Map<String, String> readAsMap(Path path) throws IOException {

		BufferedReader br = null;
		try {

			br = new BufferedReader(new InputStreamReader(openTxtOrGzipStream(path)));
			return parse(br);

		} finally {
			br.close();
		}

	}

	private static Map<String, String> parse(BufferedReader br) throws IOException {

		Map<String, String> fasta = new HashMap<String, String>();
		String sample = null;
		String line = null;
		while ((line = br.readLine()) != null) {

			String trimmedLine = line.trim();

			// ignore comments
			if (trimmedLine.isEmpty() || trimmedLine.startsWith(";")) {
				continue;
			}

			if (trimmedLine.startsWith(">")) {
				sample = trimmedLine.substring(1).trim();
				if (fasta.containsKey(sample)) {
					throw new IOException("Duplicate sample " + sample + " detected.");
				}
				fasta.put(sample, "");
			} else {
				if (sample == null) {
					throw new IOException("Fasta file is malformed. Starts with sequence.");
				}
				String sequence = fasta.get(sample);
				fasta.put(sample, sequence + trimmedLine);
			}
		}

		return fasta;

	}

	private static DataInputStream openTxtOrGzipStream(Path path) throws IOException {
		FileInputStream inputStream = new FileInputStream(path.toFile());
		InputStream in2 = decompressStream(inputStream);
		return new DataInputStream(in2);
	}

	public static InputStream decompressStream(InputStream input) throws IOException {
		// we need a pushbackstream to look ahead
		PushbackInputStream pb = new PushbackInputStream(input, 2);
		byte[] signature = new byte[2];
		pb.read(signature); // read the signature
		pb.unread(signature); // push back the signature to the stream
		// check if matches standard gzip magic number
		if (signature[0] == (byte) 0x1f && signature[1] == (byte) 0x8b)
			return new GZIPInputStream(pb);
		else
			return pb;
	}

	public static void main(String... args) {
		int exitCode = new CommandLine(new FastaUtil()).execute(args);
		System.exit(exitCode);
	}

}
