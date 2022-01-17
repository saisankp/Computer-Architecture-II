import java.time.Duration;
import java.time.Instant;

public class Tutorial3Modified {

	public static int procedureCalls = 0;
	public static int registerWindowDepth = 0;
	public static int WUSED = 0;
	public static int numberOfOverflows = 0;
	public static int numberOfUnderflows = 0;
	public static int CWP = 0;
	public static int SWP = 0;
	public static int NWINDOWS = 0;
	public static int maxRegisterWindowDepth = 0;
	
	//The main function, where we call the instrumented function three times, and measure the time elapsed to calculate compute_pascal(30,20).
	public static void main(String args[]) {
		call_compute_pascal_instrumented(30,20, 6);
		call_compute_pascal_instrumented(30,20, 8);
		call_compute_pascal_instrumented(30,20, 16);
		Instant start = Instant.now();
		compute_pascal(30, 20);
		Instant finish = Instant.now();
		long timeElapsed = Duration.between(start, finish).toMillis();
		System.out.println("My computer took " + timeElapsed + "ms to run compute_pascal(30, 20).");
	}
	
	//The release version of te code given to us.
	public static int compute_pascal(int row, int position) {
		if(position == 1) {
			return 1;
		}
		else if(position == row) {
			return 1;
		}
		else {
			return compute_pascal(row-1, position)+compute_pascal(row-1, position-1);
		}
	}
	
	//The instrumented code I made by modifying the release version of the code.
	public static int compute_pascal_instrumented(int row, int position) {
		procedureCalls++;
		if(position == 1) {
			checkforUnderflow();
			return 1;
		}
		else if(position == row) {
			checkforUnderflow();
			return 1;
		}
		else {
			checkForOverflowModified();
			int result1 = compute_pascal_instrumented(row-1, position);
			checkForOverflowModified();
			int result2 = compute_pascal_instrumented(row-1, position-1);
			checkforUnderflow();
			return result1+result2;
		}
	}
	
	//Method to check for Overflow, which should be used before a function call.
	public static void checkForOverflowModified(){
	    registerWindowDepth++;
	    if(registerWindowDepth > maxRegisterWindowDepth) {
	    	 maxRegisterWindowDepth = registerWindowDepth;
	    }
	    if(WUSED == NWINDOWS-1){
	        numberOfOverflows++;
	        SWP++;
	    }
	    else {
	        WUSED++;
	    }
	    CWP++;
	}
	
	//Method to check for Underflow, which should be used before returning.
	public static void checkforUnderflow(){
	    registerWindowDepth--;
	    if(WUSED == 2){
	        SWP--;
	        numberOfUnderflows++;
	    }
	    else {
	        WUSED--;
	    }
	    CWP--;
	}

	//Method to initialize all global variables before calling the function.
	public static void initializeVariables(){
	    WUSED = 2;
	    NWINDOWS = 0;
	    CWP = 0;
	    SWP = 0;
	    procedureCalls = 0;
	    numberOfOverflows = 0;
	    numberOfUnderflows = 0;
	    registerWindowDepth = 0;
	    maxRegisterWindowDepth = 0;
	}
	
	//Method to setup the calling of the instrumented function.
	public static void call_compute_pascal_instrumented(int a, int b, int numberOfWindows){
		try {
			initializeVariables();
			System.out.println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
		    NWINDOWS = numberOfWindows;
		    checkForOverflowModified();
		    int result = compute_pascal_instrumented(a, b);
		    System.out.println("Using a RISC-I processor with " + numberOfWindows + " register windows");
		    System.out.println("The result from compute_pascal(" + a + "," + b + ") is " + result);
		    System.out.println("The number of procedure calls is " + procedureCalls);
		    System.out.println("The maximum register window depth is " + maxRegisterWindowDepth);
		    System.out.println("The number of register window Overflows is " + numberOfOverflows);
		    System.out.println("The number of register window Underflows is " + numberOfUnderflows);
		    System.out.println("The number of register windows pushed onto the stack for each case of overlapping register windows is " + numberOfOverflows);
			System.out.println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}
