#include <ExampleEvents.h>


namespace example { 
namespace exampleevents {

    bool ExampleEventProcessor::Process (InitialEvent& oEvent){return UnexpectedEvent(oEvent.GetName());};
    bool ExampleEventProcessor::Process (IntermediateEvent& oEvent){return UnexpectedEvent(oEvent.GetName());};
    bool ExampleEventProcessor::Process (FinalEvent& oEvent) {return UnexpectedEvent(oEvent.GetName());};
}
}