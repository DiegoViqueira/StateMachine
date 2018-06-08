#ifndef _EXAMPLE_EVENTS_INCLUDED
#define _EXAMPLE_EVENTS_INCLUDED

#include <ats/base/alloc/shared_ptr.hpp>
#include <BaseEvents.h>

namespace example{
    namespace exampleevents{

            /* EVENTS forward declaration */
            class InitialEvent;
            class IntermediateEvent;
            class FinalEvent;

            /* PROCESSOR Interfase */            
            class ExampleEventProcessor
            {
                public:

                    typedef example::events::AEvent<ExampleEventProcessor> BaseEvent;
                    virtual ~ExampleEventProcessor(){};
                    virtual bool Process (InitialEvent& oEvent);
                    virtual bool Process (IntermediateEvent& oEvent);
                    virtual bool Process (FinalEvent& oEvent) ;
                    virtual bool UnexpectedEvent( const std::string& strEventName ) 
                    { std::cout<< "Unexpected Event[" << strEventName << std::endl;
                      return true;}; 
                
            };

            /* EVENTS Definition */
            
            class InitialEvent: public example::baseevents::ABaseEvent<ExampleEventProcessor,InitialEvent>
            {
            public:            
                InitialEvent():ABaseEvent("InitialEvent"){};
                std::string Data;

            };

            class IntermediateEvent: public example::baseevents::ABaseEvent<ExampleEventProcessor,IntermediateEvent>
            {
            public:            
                IntermediateEvent():ABaseEvent("IntermediateEvent"){};
                std::string Data;
            };
            
            class FinalEvent:public example::baseevents::ABaseEvent<ExampleEventProcessor,FinalEvent>
            {
                public:
                FinalEvent():ABaseEvent("FinalEvent"){};
                std::string Data;
            };



    }
}

#endif