#ifndef _BASE_EVENTS_INCLUDED
#define _BASE_EVENTS_INCLUDED

#include <ats/base/alloc/shared_ptr.hpp>
#include "Event.hpp"


namespace example{
    namespace baseevents{


        template< typename Processor, typename FinalEvent >
        class ABaseEvent: public example::events::AEvent< Processor >
        {
        public:
            ABaseEvent(const char* pszName):m_strName(pszName){}
            bool Process( Processor& oProcessor )
            {
                return oProcessor.Process( static_cast<FinalEvent&>(*this) );
            }
            const char* GetName()
            {
                return m_strName.c_str();
            }
        private:
            std::string m_strName;
        };
            
    }
}

#endif