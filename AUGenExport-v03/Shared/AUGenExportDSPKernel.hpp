/*
	<samplecode>
		<abstract>
			A DSPKernel subclass that wraps thinly the exported code from Max
		</abstract>
	</samplecode>
*/

#ifndef AUGenExportDSPKernel_hpp
#define AUGenExportDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"
#import <vector>

static inline float convertBadValuesToZero(float x) {
	/*
		Eliminate denormals, not-a-numbers, and infinities.
		Denormals will fail the first test (absx > 1e-15), infinities will fail 
        the second test (absx < 1e15), and NaNs will fail both tests. Zero will
        also fail both tests, but since it will get set to zero that is OK.
	*/
		
	float absx = fabs(x);

    if (absx > 1e-15 && absx < 1e15) {
		return x;
	}

    return 0.0;
}

static inline double squared(double x) {
    return x * x;
}

class AUGenExportDSPKernel : public DSPKernel {
public:
	
    AUGenExportDSPKernel() {}
	
	void init(int channelCount, double inSampleRate) {
		
		for (int i=0; i<gens.size(); i++) {
			CommonState *state = gens.at(i);
			gen_exported::destroy(state);
		}
		gens.clear();
		for (int i=0; i<channelCount; i++) {
			CommonState *state = (CommonState *) gen_exported::create((t_param) inSampleRate, 512);
			gens.push_back(state);
		}
	}
	
	void reset() { }
	
	void setParameter(AUParameterAddress address, AUValue value) {
		for (int i=0; i<gens.size(); i++) {
			CommonState *state = gens.at(i);
			gen_exported::setparameter(state, address, value, nil);
		}
	}

	AUValue getParameter(AUParameterAddress address) {
		t_param p = 0;
		gen_exported::getparameter(gens.at(0), address, &p);
		return p;
	}
	
	int getNumParams() {
		return gen_exported::num_params();
	}
	
	const char *getParameterIdentifier(long index) {
		return gen_exported::getparametername(gens.at(0), index);
	}
	
	bool parameterHasMinMax(long index) {
		return (bool) gen_exported::getparameterhasminmax(gens.at(0), index);
	}
	
	AUValue getParameterMin(long index) {
		return (AUValue) gen_exported::getparametermin(gens.at(0), index);
	}
	
	AUValue getParameterMax(long index) {
		return (AUValue) gen_exported::getparametermax(gens.at(0), index);
	}
	
	const char *getParameterUnits(long index) {
		return gen_exported::getparameterunits(gens.at(0), index);
	}
	
	void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override { }
	
	void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
		inBufferListPtr = inBufferList;
		outBufferListPtr = outBufferList;
	}
	
	void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
		
		// TODO: Get channel count from Gen state vector
		int channelCount = gens.size();
		
		for (int channel = 0; channel < channelCount; ++channel) {
			CommonState *gen = gens.at(channel);
			int frameOffset = int(bufferOffset);
			float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
			float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
			long ins = inBufferListPtr->mBuffers[channel].mDataByteSize;
			long outs = outBufferListPtr->mBuffers[channel].mDataByteSize;
			gen_exported::perform(gen, &in, ins, &out, outs, frameCount);
		}
	}

private:
	std::vector<CommonState *> gens;

	AudioBufferList* inBufferListPtr = nullptr;
	AudioBufferList* outBufferListPtr = nullptr;
};

#endif /* AUGenExportDSPKernel_hpp */
