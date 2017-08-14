
import hex.genmodel.easy.EasyPredictModelWrapper;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.prediction.BinomialModelPrediction;

public class Main {

	private static String modelClassName = "dl_fit3";

	  public static void main(String[] args) throws Exception {
	    hex.genmodel.GenModel rawModel;
	    rawModel = (hex.genmodel.GenModel) Class.forName(modelClassName).newInstance();
	    EasyPredictModelWrapper model = new EasyPredictModelWrapper(rawModel);
	    
	    //
	    // By default, unknown categorical levels throw PredictUnknownCategoricalLevelException.
	    // Optionally configure the wrapper to treat unknown categorical levels as N/A instead
	    // and strings that cannot be converted to numbers also to N/As:
	    //
	    //     EasyPredictModelWrapper model = new EasyPredictModelWrapper(
	    //         new EasyPredictModelWrapper.Config()
	    //             .setModel(rawModel)
	    //             .setConvertUnknownCategoricalLevelsToNa(true)
	    //             .setConvertInvalidNumbersToNa(true)
	    //     );
	    
	    RowData row = new RowData();
	     row.put("potential", "71");
	     row.put("preferred_footright", "1");
	     row.put("attacking_work_ratelow", "1");
	     row.put("attacking_work_ratemedium", "0");
	     row.put("defensive_work_ratelow", "0");
	     row.put("defensive_work_ratemedium", "1");
	     row.put("crossing", "49");
	     row.put("finishing", "44");
	     row.put("heading_accuracy", "71");
	     row.put("volleys", "44");
	     row.put("dribbling", "51");
	     row.put("curve", "45");
	     row.put("free_kick_accuracy", "39");
	     row.put("long_passing", "64");
	     row.put("ball_control", "49");
	     row.put("agility", "59");
	     row.put("reactions", "47");
	     row.put("shot_power", "55");
	     row.put("jumping", "58");
	     row.put("stamina", "54");
	     row.put("strength", "76");
	     row.put("aggression", "71");
	     row.put("interceptions", "70");
	     row.put("positioning", "45");
	     row.put("vision", "54");
	     row.put("penalties", "48");
	     row.put("marking", "65");
	     row.put("standing_tackle", "69");
	     row.put("sliding_tackle", "69");
	     row.put("gk_diving", "6");
	     row.put("gk_handling", "11");
	     row.put("gk_kicking", "10");
	     
	    BinomialModelPrediction p = model.predictBinomial(row);
	    System.out.println("Label (aka prediction): " + p.label);
	    
	    System.out.print("Class probabilities: ");
	    for (int i = 0; i < p.classProbabilities.length; i++) {
	      if (i > 0) {
	        System.out.print(",");
	      }
	      System.out.print(p.classProbabilities[i]);
	    }
	    System.out.println("");
	  }
}
